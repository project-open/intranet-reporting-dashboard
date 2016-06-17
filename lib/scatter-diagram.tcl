# /packages/sencha-reporting-portfolio/lib/scatter-diagram.tcl
#
# Copyright (C) 2011 ]project-open[
#
# All rights reserved. Please check
# http://www.project-open.com/license/ for details.

# ----------------------------------------------------------------------
# 
# ---------------------------------------------------------------------

# The following variables are expected in the environment
# defined by the calling /tcl/*.tcl libary:
#	program_id
#	diagram_width
#	diagram_height
#	sql	Defines the columns x_axis, y_axis, color and diameter

# Create a random ID for the diagram
set diagram_id "margin_tracker_[expr round(rand() * 100000000.0)]"

set x_axis 0
set y_axis 0
set color "yellow"
set diameter 5
set title ""
set axis_x_title_json ""
set axis_y_title_json ""
if {[info exists diagram_x_title] && "" ne $diagram_x_title} { set axis_x_title_json "title: '$diagram_x_title'," }
if {[info exists diagram_y_title] && "" ne $diagram_y_title} { set axis_y_title_json "title: '$diagram_y_title'," }


set data_list {}
set project_count 0
set url ""
db_foreach scatter_sql $sql {
    if {$project_count > 10} { continue }
    lappend data_list "{x_axis: $x_axis, y_axis: $y_axis, color: '$color', diameter: $diameter, caption: '$title', url: '$url'}"
    incr project_count
    
}

set data_json "\[\n"
append data_json [join $data_list ",\n"]
append data_json "\n\]\n"


# ad_return_complaint 1 "<pre>$data_json</pre>"
