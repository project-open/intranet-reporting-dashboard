# /packages/intranet-reporting-dashboard/www/top-customers.json.tcl
#
# Copyright (C) 2012 ]project-open[
#
# All rights reserved. Please check
# http://www.project-open.com/license/ for details.

ad_page_contract {
    Datasource for top-customers Sencha pie chart.
} {
    { diagram_interval "all_time" }
    { diagram_max_customers 10 }
    { diagram_max_length_customer_name 15 }
}

# ----------------------------------------------------
# Defaults & Permissions
# ----------------------------------------------------

set current_user_id [ad_conn user_id]
if {![im_permission $current_user_id view_companies_all] || ![im_permission $current_user_id view_finance]} { 
    set json "{\"success\": false, \"message\": \"Insufficient permissions - you need view_companies_all and view_finance.\" }"
    doc_return 200 "text/html" $json
    ad_script_abort
}

set default_currency [im_parameter -package_id [im_package_cost_id] "DefaultCurrency" "" "EUR"]

# ----------------------------------------------------
# Multirow as temporary store
# We need it, beacause we want to calculate the "rest"
# of the invoicing from the non-top companies.
# ----------------------------------------------------

switch $diagram_interval {
    last_year { set top_customer_interval_sql "and c.effective_date >= now()::date - 365" }
    last_quarter { set top_customer_interval_sql "and c.effective_date >= now()::date - 90" }
    last_month { set top_customer_interval_sql "and c.effective_date >= now()::date - 30" }
    all_time { set top_customer_interval_sql "" }
    default {
	set json "{\"success\": false, \"message\": \"Invalid diagram_interval option: '$diagram_interval'.\" }"
	doc_return 200 "text/html" $json
	ad_script_abort
    }
}

set top_customers_sql "
	select	company_name as customer_name,
		sum(c.amount * im_exchange_rate(c.effective_date::date, c.currency, :default_currency)) as customer_revenues
	from	im_companies cust,
		im_costs c
	where	c.customer_id = cust.company_id and
		c.cost_type_id = [im_cost_type_invoice] and
		cust.company_path != 'internal'
		$top_customer_interval_sql
	group by company_name
	order by customer_revenues DESC
"

set count 0
set other_revenues 0.0
multirow create top_customers customer_name customer_revenues
db_foreach top_customers $top_customers_sql {
    set customer_name_limited [string range $customer_name 0 $diagram_max_length_customer_name]
    if {$customer_name_limited != $customer_name} { append customer_name_limited "..." }

    if {$count < $diagram_max_customers} {
	multirow append top_customers $customer_name_limited $customer_revenues
    } else {
	set other_revenues [expr {$other_revenues + $customer_revenues}]
    }

    incr count
}

# Create dummy entry if there were no revenues
if {0 == $count} {
    set no_revenues_l10n [lang::message::lookup "" intranet-reporting-dashboard.No_Revenues "No Revenues"]
    multirow append top_customers $no_revenues_l10n 1
} else {
    set other_l10n [lang::message::lookup "" intranet-core.Rest "Rest"]
    multirow append top_customers $other_l10n $other_revenues
}

# ----------------------------------------------------
# Create JSON for data source
# ----------------------------------------------------

set data_list [list]
multirow foreach top_customers {
    lappend data_list "{\"name\": \"$customer_name\", \"value\": $customer_revenues }"
}
set json "{\"success\": true, \"message\": \"Data loaded\", \"data\": \[\n[join $data_list ",\n"]\n\]}"
doc_return 200 "text/html" $json

