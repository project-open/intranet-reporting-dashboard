# /packages/intranet-reporting-dashboard/www/project-eva.tcl
#
# Copyright (C) 2014 ]project-open[
#
# All rights reserved. Please check
# http://www.project-open.com/license/ for details.

ad_page_contract {
    Datasource for top-customers Sencha pie chart.
} {
    diagram_project_id:integer
}

# ----------------------------------------------------
# Defaults & Permissions
# ----------------------------------------------------

set current_user_id [ad_conn user_id]
im_project_permissions $current_user_id $diagram_project_id view read write admin
if {!$read} {
    set json "{\"success\": false, \"message\": \"Insufficient permissions - you need read permissions for project #$diagram_project_id.\" }"
    doc_return 200 "text/html" $json
    ad_script_abort
}

set default_currency [im_parameter -package_id [im_package_cost_id] "DefaultCurrency" "" "EUR"]
set default_hourly_cost [im_parameter -package_id [im_package_cost_id] "DefaultTimesheetHourlyCost" "" 30]

set message "Data loaded"

# ----------------------------------------------------
# Calculate diagram time points
# ----------------------------------------------------

# We need to mix SQL with TCL in order to create an efficient algorithm:
# We extract all start- and end dates from all tasks in the project and
# sort the list, so that we get a time line with the future X coordinates
# in the diagram.
# Then we define for each timeline "segment" the "inclination" of the curve,
# as defined by the resource consumption over time.
# As a result, we can draw the planned_ts_value curve and compare it with 
# values from the past.

set planned_ts_value_sql "
	select	p.*,
		CASE WHEN duration_hours = 0 THEN 0 ELSE coalesce(planned_units, 0.0) / duration_hours END as inclination,
		CASE WHEN sum_percentage = 0 THEN 0 ELSE weighted_hourly_cost * 100.0 / sum_percentage END as hourly_cost
	from	(
			select	p.tree_sortkey,
				p.project_id,
				p.project_nr,
				round(extract(epoch from p.start_date)) as start_epoch,
				round(extract(epoch from p.end_date)) as end_epoch,
				(extract(epoch from coalesce(p.end_date,p.start_date)) - extract(epoch from p.start_date)) / 3600.0 as duration_hours,
				coalesce(t.planned_units, 0.0) as planned_units,
				t.uom_id,
				(	select	sum(coalesce(e.hourly_cost, :default_hourly_cost) * coalesce(bom.percentage, 0.0) * coalesce(e.availability, 100) / 10000.0)
					from	im_biz_object_members bom,
						acs_rels r
						LEFT OUTER JOIN im_employees e on (r.object_id_two = e.employee_id)
					where	r.rel_id = bom.rel_id and
						r.object_id_one = p.project_id
				) as weighted_hourly_cost,
				(	select	sum(coalesce(bom.percentage, 0.0) * coalesce(e.availability, 100) / 100.0)
					from	im_biz_object_members bom,
						acs_rels r
						LEFT OUTER JOIN im_employees e on (r.object_id_two = e.employee_id)
					where	r.rel_id = bom.rel_id and
						r.object_id_one = p.project_id
				) as sum_percentage
			from	im_projects main_p,
				im_projects p
				LEFT OUTER JOIN im_timesheet_tasks t ON (p.project_id = t.task_id)
			where	main_p.project_id = :diagram_project_id and
				p.tree_sortkey between main_p.tree_sortkey and tree_right(main_p.tree_sortkey) and
				p.start_date is not null
		) p
	where	start_epoch is not null and
		end_epoch is not null
	order by p.tree_sortkey
"
# Write the results into a multirow, because we'll need it twice
db_multirow mr planned_ts_value_sql $planned_ts_value_sql


# First pass: Collect all start and end points of project tasks
set total_planned_ts_value 0.0
template::multirow foreach mr {
    set timeline_hash($start_epoch) 1
    set timeline_hash($end_epoch) 1
    if {"" == $hourly_cost} {
	ns_log Error "project-eva.json.tcl: found empty hourly_cost project project #$project_id, using default=$default_hourly_cost"
	set message "Data loaded. Warning: Using default hourly_cost=$default_hourly_cost"
	set hourly_cost $default_hourly_cost
    }
    set total_planned_ts_value [expr {$total_planned_ts_value + $planned_units * $hourly_cost}]
}

set timeline_list [lsort -integer [array name timeline_hash]]

# Create a reverted index on the timeline_list, so that we can 
# find the index for each epoch quickly. This will reduce the
# complexity of the algorithm to N*log(N)
set ctr 0
foreach epoch $timeline_list {
    set epoch_hash($epoch) $ctr
    incr ctr
}

# Second pass: Sum up the inclination for each segment
array set inclination_hash {}
template::multirow foreach mr {
    set start_idx $epoch_hash($start_epoch)
    set end_idx $epoch_hash($end_epoch)
    
    ns_log Notice "project-eva: start_idx=$start_idx, end_idx=$end_idx, inclination=$inclination"

    for {set i $start_idx} {$i < $end_idx} {incr i} {
	set incl 0.0
	if {[info exists inclination_hash($i)]} { set incl $inclination_hash($i) }
	set incl [expr {$incl + $inclination * $hourly_cost}]
	set inclination_hash($i) $incl
    }
}

# ad_return_complaint 1 [array get inclination_hash]

# ----------------------------------------------------
# Integrate the graph up
# ----------------------------------------------------


set timeline_list_len [expr {[llength $timeline_list] - 1}]
set value 0.0
array set planned_ts_value_hash {}
set planned_ts_value_hash(0) $value
for {set i 0} {$i < $timeline_list_len} {incr i} {
    set start_epoch [lindex $timeline_list $i]
    set end_epoch [lindex $timeline_list $i+1]

    set inclination 0.0
    if {[info exists inclination_hash($i)]} { set inclination $inclination_hash($i) }
    set duration_hours [expr ($end_epoch - $start_epoch) / 3600.0]
    set delta [expr {$duration_hours * $inclination}]
    set value [expr {$value + $delta}]

    ns_log Notice "project-eva: i=$i: start:[im_date_epoch_to_ansi $start_epoch] [im_date_epoch_to_time $start_epoch], end:[im_date_epoch_to_ansi $end_epoch] [im_date_epoch_to_time $end_epoch], duration_hours=$duration_hours, inclination=$inclination, delta=$delta, value=$value"
    set planned_ts_value_hash([expr {$i+1}]) $value
}


# ----------------------------------------------------
# Show Financial documents during intervals
# ----------------------------------------------------

set cost_type_sql "select * from im_cost_types"
db_foreach cost_types $cost_type_sql {
    set cost_type_hash($cost_type_id) $short_name
}

set timesheet_sql "
	select	main_p.project_budget,
		main_p.project_budget_hours,
		extract(epoch from c.effective_date) as effective_epoch,
		c.*
	from	im_projects main_p,
		im_projects p,
		im_costs c
	where	main_p.project_id = :diagram_project_id and
		p.tree_sortkey between main_p.tree_sortkey and tree_right(main_p.tree_sortkey) and
		c.project_id = p.project_id
	order by
		c.cost_type_id,
		c.effective_date
"
set old_cost_type_id 0
array set cost_hash {}
db_foreach ts $timesheet_sql {

    # Initiate the index to the timeline
    if {$cost_type_id != $old_cost_type_id} {

	# Fill the cost_hash until the end of the last cost_type_id
	while {0 != $old_cost_type_id && $ctr < $timeline_list_len} {
	    ns_log Notice "project-eva.json: fill: ctr=$ctr, cost_type_id=$cost_type_id, amount=$amount"
	    incr ctr
	    set key "$old_cost_type_id-$ctr"
	    set cost_hash($key) $value
	}

	set value 0.0
	set ctr 0
	set ctr_epoch [lindex $timeline_list $ctr]
	set old_cost_type_id $cost_type_id
    }

    ns_log Notice "project-eva.json: ctr=$ctr, cost_type_id=$cost_type_id, amount=$amount"

    # Calculate the timeline slot for the cost item
    while {$effective_epoch > $ctr_epoch && $ctr < $timeline_list_len} {
	incr ctr
	set ctr_epoch [lindex $timeline_list $ctr]
    }

    # Update the hash
    set key "$cost_type_id-$ctr"
    set value [expr {$value + $amount}]
    set cost_hash($key) $value
}

# Fill the cost_hash until the end of the last cost_type_id
while {0 != $old_cost_type_id && $ctr < $timeline_list_len} {
    ns_log Notice "project-eva.json: fill: ctr=$ctr, cost_type_id=$cost_type_id, amount=$amount"
    incr ctr
    set key "$old_cost_type_id-$ctr"
    set cost_hash($key) $value
}



# ----------------------------------------------------
# Create JSON for data source
# ----------------------------------------------------

set ctr 0
set json_lines {}
foreach epoch $timeline_list {
    set planned_ts_value [expr {round(100.0 * $planned_ts_value_hash($ctr)) / 100.0}]

    set json_values [list]
    lappend json_values "'date': '[im_date_epoch_to_ansi $epoch] [im_date_epoch_to_time $epoch]'"
    lappend json_values "'planned_ts_value': $planned_ts_value"
    lappend json_values "'total_planned_ts_value': $total_planned_ts_value"

    foreach cost_type_id [array names cost_type_hash] {
	set cost_type_name $cost_type_hash($cost_type_id)
	if {"unknown" == $cost_type_name} { continue }
	set key "$cost_type_id-$ctr"
	set value 0.0
	if {[info exists cost_hash($key)]} { set value $cost_hash($key) }
	lappend json_values "'$cost_type_hash($cost_type_id)': $value"
    }

    lappend json_lines "{[join $json_values ", "]}"
    incr ctr
}

set json "{\"success\": true, \"message\": \"$message\", \"data\": \[\n[join $json_lines ",\n"]\n\]}"
doc_return 200 "text/html" $json

