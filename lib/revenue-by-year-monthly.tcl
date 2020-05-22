# /packages/intranet-reporting-dashboard/lib/revenue-per-month.tcl
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
if {![info exists diagram_default_interval] || "" eq $diagram_default_interval} { set diagram_default_interval "last_year" }
if {![info exists diagram_default_fact] || "" eq $diagram_default_fact} { set diagram_default_fact "revenue" }
if {![info exists diagram_min_start_date]} { set diagram_min_start_date "2015-01-01" }


# ----------------------------------------------------
# Diagram Setup
# ----------------------------------------------------

# Create a random ID for the diagram
set diagram_rand [expr {round(rand() * 100000000.0)}]
set diagram_id "revenue_by_month_$diagram_rand"
set default_currency [im_parameter -package_id [im_package_cost_id] "DefaultCurrency" "" "EUR"]


# Get the list of all years
set year_list [db_list year_list "select distinct 'invoices_' || to_char(im_month_enumerator, 'YYYY') as year from im_month_enumerator(:diagram_min_start_date::date, now()::date) order by year"]
set year_list_names [db_list year_list_names "select distinct to_char(im_month_enumerator, 'YYYY') as year from im_month_enumerator(:diagram_min_start_date::date, now()::date) order by year"]
set year_list_json "\['[join $year_list "', '"]'\]"

# The header of the Sencha store:
set header_list [linsert $year_list 0 "month"]
set header_json "\['[join $header_list "', '"]'\]"

# Series JSON
set series_list {}
set cnt 0
foreach year $year_list {
    set year_name [lindex $year_list_names $cnt]
    lappend series_list "{
                type: 'line',
                title: '$year_name',
                xField: 'month', yField: '$year', 
                axis: 'left', 
                highlight: {size: 7, radius: 7},
		listeners: {
		    'itemclick': function(item, event) {
		        var date = item.storeItem.get('Year').toISOString().substring(0,10);
			var value = item.value\[1\];
			var year = item.series.yField;
			var url = '/intranet-reporting-dashboard/revenue-by-year-monthly-details';
			url = url + '?month='+month+'&year='+year;
			window.open(url, '_blank');
		    }	   
		},
                tips: { width: 200, renderer: function(storeItem, item) { 
                    this.setTitle('$year:<br>Year: '+storeItem.get('Year').toISOString().substring(0,7)+',<br> Revenues: '+storeItem.get('$year')); 
                }}
            }"
    incr cnt
}
set series_list_json "\[\n            [join $series_list ",\n            "]\n        \]"

