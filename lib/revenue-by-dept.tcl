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
if {![info exists diagram_dept_sql]} { set diagram_dept_sql "" }
if {![info exists diagram_intervall]} { set diagram_interval "last_year" }
if {![info exists diagram_fact]} { set diagram_fact "revenue" }
if {![info exists diagram_min_start_date]} { set diagram_min_start_date "2015-01-01" }


# ----------------------------------------------------
# dept_sql - how to determine the department or area?
# ----------------------------------------------------

set default_diagram_dept_sql "coalesce((select cost_center_name from im_cost_centers where cost_center_id = project_cost_center_id), 'none')"
if {"" eq $diagram_dept_sql} {
    set diagram_dept_sql $default_diagram_dept_sql
}
# Classifier
# set dept_sql "coalesce(acs_object__name(project_cost_center_id), 'none')"
# set dept_sql "coalesce(im_category_from_id(aec_area_id), 'none')"
# set dept_sql "coalesce((select cost_center_name from im_cost_centers where cost_center_id = project_cost_center_id), 'none')"
set diagram_dept_sql "coalesce((select category from im_categories where category_id = aec_area_id), 'none')"


# ----------------------------------------------------
# Diagram Setup
# ----------------------------------------------------

# Create a random ID for the diagram
set diagram_rand [expr {round(rand() * 100000000.0)}]
set diagram_id "revenu_by_dept_$diagram_rand"
set default_currency [im_parameter -package_id [im_package_cost_id] "DefaultCurrency" "" "EUR"]


# Get the list of all departments
set dept_list [db_list dept_list "select dept from (select distinct $diagram_dept_sql as dept from im_projects) t order by lower(dept)"]
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
                tips: { width: 200, renderer: function(storeItem, item) { 
                    this.setTitle('$dept:<br>Date: '+storeItem.get('Date').toISOString().substring(0,10)+',<br> Revenues: '+storeItem.get('$dept')); 
                }}
            }"
}
set series_list_json "\[\n            [join $series_list ",\n            "]\n        \]"
