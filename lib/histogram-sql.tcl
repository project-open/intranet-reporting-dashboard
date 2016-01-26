# /packages/intranet-reporting-dashboard/lib/histogram-sql.tcl
#
# Copyright (C) 2014 ]project-open[
#
# All rights reserved. Please check
# http://www.project-open.com/license/ for details.

# ----------------------------------------------------------------------
# Variables
# ---------------------------------------------------------------------

# The following variables are expected in the environment
# defined by the calling /tcl/*.tcl libary:
if {![info exists diagram_width]} { set diagram_width 600 }
if {![info exists diagram_title]} { set diagram_title "" }

# Create a random ID for the diagram
set diagram_rand [expr {round(rand() * 100000000.0)}]
set diagram_id "histogram_sql_$diagram_rand"

# Execute the sql and create inline store code.
set json_list [list]
db_with_handle db {
    set selection [db_exec select $db query $sql 1]
    while { [db_getrow $db $selection] } {
	set col_names [ad_ns_set_keys $selection]
	set json_entry ""
	for { set i 0 } { $i < [ns_set size $selection] } { incr i } {
	    set var [lindex $col_names $i]
	    set val [ns_set value $selection $i]
	    switch $i {
		0 { append json_entry "\{category: '$val'" }
		1 { append json_entry ", value: $val\}" }
		default { ad_return_complaint "histogram-sql: The provided SQL statement returns more the two columns. 
                     Expected: column 1 should contain a category string, column 2 should contain a numerical value" }
	    }
	}
	lappend json_list $json_entry
    }
}
db_release_unused_handles
set store_json [join $json_list ",\n\t"]


# Calculate diagram height depending on SQL output
if {![info exists diagram_height]} { 
    set diagram_height [expr 60 + [llength json_list] * 15]
}
