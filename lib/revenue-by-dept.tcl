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
if {![info exists diagram_title] || "" eq $diagram_title} { set diagram_title [lang::message::lookup "" intranet-reporting-dashboard.Revenue_by_Department "Revenue by Department"] }
if {![info exists diagram_dept_sql]} { set diagram_dept_sql "" }
if {![info exists diagram_default_interval] || "" eq $diagram_default_interval} { set diagram_default_interval "last_year" }
if {![info exists diagram_default_fact] || "" eq $diagram_default_fact} { set diagram_default_fact "revenue" }
if {![info exists diagram_min_start_date]} { set diagram_min_start_date "2015-01-01" }

set enable_total_p [parameter::get_from_package_key -package_key "intranet-reporting-dashboard" -parameter RevenueByDeptWithTotalP -default 1]
set use_quotes_as_proxy_for_invoices_days [parameter::get_from_package_key -package_key "intranet-reporting-dashboard" -parameter RevenueByDeptUseQuotesAsProxyForInvoicesDays -default 0]

# ----------------------------------------------------
# dept_sql - how to determine the department or area?
# ----------------------------------------------------

# ad_return_complaint 1 $diagram_dept_sql

set default_diagram_dept_sql "coalesce((select cost_center_name from im_cost_centers where cost_center_id = project_cost_center_id), 'none')"
if {"" eq $diagram_dept_sql} {
    set diagram_dept_sql $default_diagram_dept_sql
}
# Classifier
# set dept_sql "coalesce(acs_object__name(project_cost_center_id), 'none')"
# set dept_sql "coalesce(im_category_from_id(aec_area_id), 'none')"
# set dept_sql "coalesce((select cost_center_name from im_cost_centers where cost_center_id = project_cost_center_id), 'none')"
# set diagram_dept_sql "coalesce((select category from im_categories where category_id = aec_area_id), 'none')"


# ----------------------------------------------------
# Diagram Setup
# ----------------------------------------------------

# Create a random ID for the diagram
set diagram_rand [expr {round(rand() * 100000000.0)}]
set diagram_id "revenu_by_dept_$diagram_rand"
set default_currency [im_parameter -package_id [im_package_cost_id] "DefaultCurrency" "" "EUR"]


# Get the list of all departments
set dept_list [db_list dept_list "select dept from (select distinct $diagram_dept_sql as dept from im_projects) t order by lower(dept)"]
if {$enable_total_p} { set dept_list [lappend dept_list "Total"] }
set dept_list_json "\['[join $dept_list "', '"]'\]"

# The header of the Sencha store:
set header_list [linsert $dept_list 0 "Date"]
set header_json "\['[join $header_list "', '"]'\]"

# Series JSON
set series_list {}
foreach dept $dept_list {
    lappend series_list "{
                type: 'line',
                title: '$dept', 
                xField: 'Date', yField: '$dept', 
                axis: 'left', 
                highlight: {size: 7, radius: 7},
		listeners: {
		    'itemclick': function(item, event) {
		        var date = item.storeItem.get('Date').toISOString().substring(0,10);
			var value = item.value\[1\];
			var dept = item.series.yField;
			var url = '/intranet-reporting-dashboard/revenue-by-dept-details';
			url = url + '?date='+date;
			url = url +'&dept='+dept +'&dept_sql=[im_quotejson $diagram_dept_sql]';
			window.open(url, '_blank');
		    }	   
		},
                tips: { width: 200, renderer: function(storeItem, item) { 
                    this.setTitle('$dept:<br>Date: '+storeItem.get('Date').toISOString().substring(0,7)+',<br> Revenues: '+storeItem.get('$dept')); 
                }}
            }"
}
set series_list_json "\[\n            [join $series_list ",\n            "]\n        \]"


# Show Axis only until 1st of current month.
# Everything within the current month is vague,
# because invoices are probably not yet written...
set axis_to_date [db_string to_date "select to_char(now(), 'YYYY-MM-01')"]
