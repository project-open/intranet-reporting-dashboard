# /packages/intranet-reporting-dashboard/www/revenue-by-dept-data-source.tcl
#
# Copyright (C) 2019 ]project-open[
#
# All rights reserved. Please check
# https://www.project-open.com/license/ for details.

# ----------------------------------------------------------------------
#
# ---------------------------------------------------------------------

ad_page_contract {
    Datasource for revenues-by-dept Sencha line chart.
    <ul>
    <li>diagram_interval options include "all_time", "last_year", "last_quarter" and "last_month"
    <li>diagram_fact options include "revenue", "profit", "internal_cost" and "external_cost"
    <li>diagram_dept_sql is a piece of SQL that extracts the department (or any other value)
    from the im_projects table. Options include:
    <ul>
    <li>department: "coalesce((select cost_center_name from im_cost_centers where cost_center_id = project_cost_center_id), 'none')"
    <li>project type: "coalesce(im_category_from_id(project_type_id), 'none')"
    <li>area (assuming im_projects.area_id): "coalesce(im_category_from_id(area_id), 'none')"
    </ul>
} {
    { diagram_interval "all_time" }
    { diagram_dept_sql "" }
    { diagram_fact "revenue" }
    { diagram_min_start_date "2015-01-01" }
}

# ----------------------------------------------------
# Defaults & Permissions
# ----------------------------------------------------

set current_user_id [ad_conn user_id]
if {![im_permission $current_user_id view_companies_all] || ![im_permission $current_user_id view_finance]} { 
    set json "{\"success\": false, \"message\": \"Insufficient permissions - you need view_companies_all and view_finance.\" }"
    doc_return 400 "application/json" $json
    ad_script_abort
}

set enable_total_p [parameter::get_from_package_key -package_key "intranet-reporting-dashboard" -parameter "RevenueByDeptWithTotalP" -default 1]
set default_currency [im_parameter -package_id [im_package_cost_id] "DefaultCurrency" "" "EUR"]
set use_quotes_as_proxy_for_invoices_days [parameter::get_from_package_key -package_key "intranet-reporting-dashboard" -parameter RevenueByDeptUseQuotesAsProxyForInvoicesDays -default 0]


set default_diagram_dept_sql "coalesce((select cost_center_name from im_cost_centers where cost_center_id = project_cost_center_id), 'none')"
if {"" eq $diagram_dept_sql} {
    set diagram_dept_sql $default_diagram_dept_sql
}

# Check for hack attack
if {[regexp {\;\:} $diagram_dept_sql match]} {
   im_security_alert -location "revenue-by-dept.json.tcl" -message "SQL injection attempt" -value $diagram_dept_sql
   set diagram_dept_sql $default_diagram_dept_sql
}



# ----------------------------------------------------
#
# ----------------------------------------------------

switch $diagram_interval {
    all_time { set diagram_start_date [db_string all_time "
	select greatest(min(start_date)::date, :diagram_min_start_date::date) from im_projects where parent_id is null
    "] }
    last_year { set diagram_start_date [db_string year "select now()::date - 365 - 31"] }
    last_two_years { set diagram_start_date [db_string year "select now()::date - 365*2 - 31"] }
    last_quarter { set diagram_start_date [db_string year "select now()::date - 90 - 31"] }
    default {
	set json "{\"success\": false, \"message\": \"Invalid diagram_interval option: '$diagram_interval'.\" }"
	doc_return 400 "application/json" $json
	ad_script_abort
    }
}

# ----------------------------------------------------
# <fact> by department
# ----------------------------------------------------

set middle_sql "
	select	main_p.project_id,
		main_p.project_name,
		main_p.start_date, 
		main_p.end_date,
		main_p.department,
		revenue * now_percent / 100.0 / 1000.0 as now_revenue,
		external_cost * now_percent / 100.0 / 1000.0 as now_external_cost,
		internal_cost * now_percent / 100.0 / 1000.0 as now_internal_cost,
		(revenue * now_percent - external_cost * now_percent - internal_cost * now_percent) / 100.0 / 1000.0 as now_profit
	from
		(select	*,
			round(CASE
				WHEN (:now::date - end_date) > 0 THEN 100.0			-- project finished
				WHEN (:now::date - start_date) < 0 THEN 0.0			-- not yet started
				ELSE 100.0 * (:now::date - start_date) / (greatest(1, end_date -  start_date))	-- in course
			END,2) as now_percent
		from	(
				select	project_id,
					project_name,
					$diagram_dept_sql as department,
					start_date::date as start_date,
					-- Handle the case of projects with bad start- and end_date
					greatest(end_date::date, start_date::date + (cost_invoices_cache/5000)::integer) as end_date,
					project_status_id,
					cost_invoices_cache as revenue,
					cost_bills_cache as external_cost,
					cost_timesheet_logged_cache + cost_expense_logged_cache as internal_cost
				from	im_projects
				where	parent_id is null and
					start_date is not null and
					project_status_id not in ([im_project_status_deleted]) and
					end_date >= :diagram_start_date::date
			) p
		) main_p
"

# set now [db_string now "select now()::date"]
# ad_return_complaint 1 [im_ad_hoc_query -format html "$middle_sql"]

set revenue_sql "
select
	department,
	sum(now_revenue) as revenue,
	sum(now_external_cost) as external_cost,
	sum(now_internal_cost) as internal_cost,
	sum(now_profit) as profit
from
	($middle_sql) t
group by department
order by department
"


# ----------------------------------------------------
# Dimensions
# ----------------------------------------------------

# Get the list of all departments
set dept_list [db_list dept_list "select dept from (select distinct $diagram_dept_sql as dept from im_projects) t order by lower(dept)"]

# Get the month dimension
set months [db_list months "select * from im_month_enumerator(:diagram_start_date::date, now()::date)"]



# ----------------------------------------------------
# Start looping
# ----------------------------------------------------


foreach dept $dept_list { set hash_old($dept-revenue) 0.0 }
set rev_rows {}
set cnt 0
foreach now $months {

    set rev_line [list "'Date': new Date(\"$now\")"]
    array unset hash

    db_foreach rev $revenue_sql {
        set hash($department-revenue) $revenue
        set hash($department-internal_cost) $internal_cost
        set hash($department-external_cost) $external_cost
        set hash($department-profit) $profit
    }

    # Extract a list of revenues by dept, following the list of depts
    set total 0.0
    foreach dept $dept_list {
	set value 0.0; # current value
	if {[info exists hash($dept-$diagram_fact)]} { set value $hash($dept-$diagram_fact) }

	set old_value 0.0; # value from last month
	if {[info exists hash_old($dept-$diagram_fact)]} { set old_value $hash_old($dept-$diagram_fact) }

	set hash_old($dept-$diagram_fact) $value; # update the old value for next iteration

	set diff [expr round(1000.0 * ($value - $old_value)) / 1000.0]
	lappend rev_line "'$dept': $diff"

	set total [expr $total + $diff]
    }

    if {$enable_total_p} {
	set total [expr round(1000.0 * $total) / 1000.0]
	lappend rev_line "'Total': $total"
    }

    # Skip the first row, because it starts with 0
    if {$cnt > 0} {
	lappend rev_rows "\{[join $rev_line ", "]\}"
    }
    incr cnt
}


# ----------------------------------------------------
# Create JSON for data source
# ----------------------------------------------------

set json "{\"success\": true, \"message\": \"Data loaded\", \"data\": \[\n[join $rev_rows ",\n"]\n\]}"
doc_return 200 "application/json" $json

