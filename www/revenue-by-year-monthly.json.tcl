# /packages/intranet-reporting-dashboard/www/revenue-by-year-monthly.tcl
#
# Copyright (C) 2019 ]project-open[
#
# All rights reserved. Please check
# https://www.project-open.com/license/ for details.

# ----------------------------------------------------------------------
#
# ---------------------------------------------------------------------

ad_page_contract {
    Datasource for revenues-by-year-monthly Sencha line chart.
    <ul>
    <li>diagram_interval sets the number of years to include
    <li>diagram_fact options include "revenue", "profit", "internal_cost" and "external_cost"
    </ul>
} {
    { diagram_interval "3" }
    { diagram_fact "revenue" }
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

set default_currency [im_parameter -package_id [im_package_cost_id] "DefaultCurrency" "" "EUR"]

set today_year [db_string today "select to_char(now(), 'YYYY')"]
set start_year [expr $today_year - $diagram_interval]
set today_date "$today_year-01-01"
set start_date "$start_year-01-01"

set next_start_year [expr $start_year + 1]
set next_start_date "$next_start_year-01-01"

set months_sql "select distinct to_char(im_month_enumerator, 'MM') as month from im_month_enumerator('$start_date'::date, '$next_start_date'::date) order by month"
set months [db_list months $months_sql]

# ----------------------------------------------------
# <fact> by department
# ----------------------------------------------------

set year_sql_list [list]
for {set year $start_year} {$year <= $today_year} {incr year} {
    lappend year_sql_list "
		,(	select	coalesce(sum(c.amount), 0.0)
			from	im_costs c
			where	c.cost_type_id = 3700 and 
				to_char(c.effective_date, 'YYYY') = '$year' and 
				to_char(c.effective_date, 'MM') = months.month
		) as invoices_$year"
}

set sql "
	select  'month_' || months.month || '' as month
		[join $year_sql_list "\n"]
	from	($months_sql) months
"
# ad_return_complaint 1 [im_ad_hoc_query -format html "$sql"]


# ----------------------------------------------------
# Create JSON for data source
# ----------------------------------------------------


set json [im_sencha_sql_to_store -data_source_p 1 -sql $sql]
doc_return 200 "application/json" $json

