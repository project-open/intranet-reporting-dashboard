# /packages/intranet-reporting-dashboard/lib/revenue-by-dept.tcl
#
# Copyright (C) 2019 ]project-open[
#
# All rights reserved. Please check
# http://www.project-open.com/license/ for details.

# ----------------------------------------------------------------------
# Variables
# ---------------------------------------------------------------------

# The following variables are expected in the environment
# defined by the calling /tcl/*.tcl libary:
if {![info exists diagram_width]} { set diagram_width 600 }
if {![info exists diagram_height]} { set diagram_height 500 }
if {![info exists diagram_title]} { set diagram_title [lang::message::lookup "" intranet-reporting-dashboard.Revenue_by_Department "Revenue by Department"] }

# ----------------------------------------------------
# Diagram Setup
# ----------------------------------------------------

# Create a random ID for the diagram
set diagram_rand [expr {round(rand() * 100000000.0)}]
set diagram_id "revenu_by_dept_$diagram_rand"
set default_currency [im_parameter -package_id [im_package_cost_id] "DefaultCurrency" "" "EUR"]

set invoice_finished_period 30

# ----------------------------------------------------
# Revenues by department
#
# Note: Depending on the status and the time since the end 
# of the project we have to take different formulas for value
# and costs:
# - Up to 30 days after closing the project there may be new 
#   invoices or provider bills
# - projects in status "closed lost" may have quotes, but 
#   should have to invoices, so "revenue" should be zero.
# ----------------------------------------------------

set revenue_sql "
select
	department,
	sum(now_revenue) as revenue,
	sum(now_external_cost) as external_cost,
	sum(now_internal_cost) as internal_cost,
	sum(now_profit) as profit
from
	(select
		main_p.project_id,
		main_p.department,
		-- main_p.project_name,
		-- main_p.start_date,
		-- main_p.end_date,
		CASE WHEN status_id in (71, 72, 73, 74, 75, 77, 82, 83, 10000408) THEN 0.0 
		ELSE round(revenue * now_percent / 100000.0) END as now_revenue,
		round(external_cost * now_percent / 100000.0) as now_external_cost,
		round(internal_cost * now_percent / 100000.0) as now_internal_cost,
		CASE WHEN status_id in (77, 82, 83, 10000408) THEN 0.0 ELSE round(revenue * now_percent / 100000.0) END
		- round(external_cost * now_percent / 100000.0) - round(internal_cost * now_percent / 100000.0) as now_profit
	from
		(select
			main_p.project_id as project_id,
			main_p.project_name as project_name,
			coalesce(im_category_from_id(aec_area_id), 'none') as department,
			main_p.start_date::date as start_date,
			main_p.end_date::date as end_date,
			main_p.project_status_id as status_id,
		
			round(CASE
				WHEN (:now::date - main_p.end_date::date) > 0 THEN 100.0		-- project finished
				WHEN (:now::date - main_p.start_date::date) < 0 THEN 0.0		-- not yet started
				ELSE 100.0 * (:now::date - main_p.start_date::date) / 
				     (greatest(1, main_p.end_date::date -  main_p.start_date::date))	-- in course
			END,2) as now_percent,
	
			main_p.project_budget as budget,
	
			-- Revenue - 30 days after project end all invoices have been written.
			-- Before that we assume that the quoted amount will be invoiced later.
			CASE WHEN :now::date - main_p.end_date::date > :invoice_finished_period 
			THEN greatest(main_p.cost_invoices_cache, main_p.project_budget)
			ELSE greatest(main_p.cost_invoices_cache, main_p.cost_quotes_cache, main_p.project_budget)
			END as revenue,
	
			-- External costs - 30 days after project end all provider bills have been written.
			-- Before we assume that all Purchase Orders will convert to bills.
			CASE WHEN :now::date - main_p.end_date::date > :invoice_finished_period
			THEN main_p.cost_purchase_orders_cache
			ELSE greatest(main_p.cost_purchase_orders_cache, main_p.cost_bills_cache)
			END as external_cost,
	
			main_p.cost_timesheet_logged_cache + main_p.cost_expense_logged_cache as internal_cost
	
		from	im_projects main_p
		where	main_p.parent_id is null and
			main_p.end_date >= :first_project_start::date
		) main_p
	where
		revenue > 0.0

	) t
group by department
order by department
"


# Get the list of all departments
set dept_list [db_list dept_list "select distinct im_category_from_id(aec_area_id) from im_projects order by im_category_from_id(aec_area_id)"]
set dept_list_json "\['[join $dept_list "', '"]'\]"


set series_list {}
foreach dept $dept_list {
    lappend series_list "{
                type: 'line',
                title: '$dept', 
                xField: 'Date', yField: '$dept', 
                axis: 'left', 
                highlight: {size: 7, radius: 7},
                tips: { width: 200, renderer: function(storeItem, item) { 
                    this.setTitle('$dept:<br>Date: '+storeItem.get('Date').toISOString().substring(0,10)+',<br> Revenues: '+storeItem.get('$dept')); 
                }}
            }"
}
set series_list_json "\[\n            [join $series_list ",\n            "]\n        \]"



# Get the month dimension
set first_project_start [db_string first_project "select greatest(min(start_date), now()::date - 365*2) from im_projects" -default "2010-01-01"]
set months [db_list months "select * from im_month_enumerator(:first_project_start::date, now()::date)"]

# The header of the Sencha store:
set header_list [linsert $dept_list 0 "Date"]
set header_json "\['[join $header_list "', '"]'\]"


# ----------------------------------------------------
# Start looping
# ----------------------------------------------------


foreach dept $dept_list { set rev_hash_old($dept) 0.0 }


set rev_rows {}
foreach now $months {

    set rev_line [list "'Date': new Date(\"$now\")"]
    array unset rev_hash

    db_foreach rev $revenue_sql {
        set rev_hash($department) $revenue
        set int_cost_hash($department) $internal_cost
        set ext_cost_hash($department) $external_cost
        set profit_hash($department) $profit
    }

    # Extract a list of revenues by dept, following the list of depts
    foreach dept $dept_list {
	set value 0.0; # current value
	if {[info exists rev_hash($dept)]} { set value $rev_hash($dept) }

	set old_value 0.0; # value from last month
	if {[info exists rev_hash_old($dept)]} { set old_value $rev_hash_old($dept) }

	set rev_hash_old($dept) $value; # update the old value for next iteration

	set diff [expr $value - $old_value]
	lappend rev_line "'$dept': $diff"

    }

    lappend rev_rows "\{[join $rev_line ", "]\}"
}

# Join the rows together to a store
set data "        [join $rev_rows ",\n        "]"

