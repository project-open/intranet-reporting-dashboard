# /packages/intranet-reporting-dashboard/lib/top-customers.tcl
#
# Copyright (C) 2012 ]project-open[
#
# All rights reserved. Please check
# http://www.project-open.com/license/ for details.

# ----------------------------------------------------------------------
# Variables
# ---------------------------------------------------------------------

# The following variables are expected in the environment
# defined by the calling /tcl/*.tcl libary:
if {![info exists diagram_width]} { set diagram_width 600 }
if {![info exists diagram_height]} { set diagram_height 400 }
if {![info exists diagram_max_customers]} { set diagram_max_customers 10 }
if {![info exists diagram_title]} { set diagram_title [lang::message::lookup "" intranet-reporting-dashboard.Top_Cusomers "Top Customers"] }

set max_length_customer_name 15


# ----------------------------------------------------
# Diagram Setup
# ----------------------------------------------------

# Create a random ID for the diagram
set diagram_rand [expr round(rand() * 100000000.0)]
set diagram_id "top_customers_$diagram_rand"

set default_currency [ad_parameter -package_id [im_package_cost_id] "DefaultCurrency" "" "EUR"]


# ----------------------------------------------------
# Create a "multirow" to show the results
# ----------------------------------------------------

set top_customers_sql "
	select	company_name as customer_name,
		sum(c.amount * im_exchange_rate(c.effective_date::date, c.currency, :default_currency)) as customer_revenues
	from	im_companies cust,
		im_costs c
	where	c.customer_id = cust.company_id and
		c.cost_type_id = [im_cost_type_invoice] and
		cust.company_path != 'internal'
	group by company_name
	order by customer_revenues DESC
"

multirow create top_customers customer_name customer_revenues

set count 0
set other_revenues 0.0
db_foreach top_customers $top_customers_sql {
    set customer_name_limited [string range $customer_name 0 $max_length_customer_name]
    if {$customer_name_limited != $customer_name} { append customer_name_limited "..." }

    if {$count < $diagram_max_customers} {
	multirow append top_customers $customer_name_limited $customer_revenues
    } else {
	set other_revenues [expr $other_revenues + $customer_revenues]
    }

    incr count
}
set other_l10n [lang::message::lookup "" intranet-core.Other "Other"]
multirow append top_customers $other_l10n $other_revenues
