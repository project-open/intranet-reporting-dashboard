# /packages/intranet-reporting-dashboard/lib/histogram-sql.tcl
#
# Copyright (C) 2014 ]project-open[
#
# All rights reserved. Please check
# http://www.project-open.com/license/ for details.

if {![info exists diagram_title]} { set diagram_title "" }

# Random ID for the diagram
set diagram_rand [expr {round(rand() * 100000000.0)}]
set diagram_id "histogram_sql_$diagram_rand"

# JSON
set name_list           [list]
set name_list_quoted    [list]
set l10n_list           [list]

# Set width/height
if {![info exists diagram_width]} { set diagram_width 400 }
if {![info exists diagram_height]} {
    set cnt [db_string sql "select count(*) from ($sql) t" -default 0]
    set diagram_height [expr 50 + $cnt * 25]
}
if {$diagram_height < 100} { set diagram_height 100 }


# Get JSON from DB
set sql "select
                array_to_json(array_agg(row_to_json(t)))
        from
                ($sql) t
        "
set store_json [db_string get_json_for_histogram $sql -default ""]

# Building lists
foreach {x y} [lindex [json::json2dict $store_json] 0] {
    lappend name_list $x
    lappend name_list_quoted "'$x'"

    # Not used - has issues with l10n
    # lappend l10n_list [lang::message::lookup "" intranet-reporting-dashboard.$x "$x"]
}

set fields [join $name_list_quoted ", "]

# Other chart types might be supported in the future
set chart_type "default"

if { "default" eq $chart_type } {
    set axes_left_value   [lindex $name_list 0]
    set axes_bottom_value [lindex $name_list 1]
}

# Clean up - not sure if still required with OpenACS 5.x
db_release_unused_handles
