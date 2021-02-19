# /packages/intranet-reporting-dashboard/www/project-phases-volume.tcl
#
# Copyright (C) 2014 ]project-open[
#
# All rights reserved. Please check
# https://www.project-open.com/license/ for details.

ad_page_contract {
    Datasource for top-customers Sencha pie chart.
} {

}

# ----------------------------------------------------
# Defaults & Permissions
# ----------------------------------------------------

set current_user_id [ad_conn user_id]
if {![im_permission $current_user_id view_finance]} {
    set json "{\"success\": false, \"message\": \"Insufficient permissions - you need the view_finance privilege to see this page.\" }"
    doc_return 400 "application/json" $json
    ad_script_abort
}

set default_currency [im_parameter -package_id [im_package_cost_id] "DefaultCurrency" "" "EUR"]
set default_hourly_cost [im_parameter -package_id [im_package_cost_id] "DefaultTimesheetHourlyCost" "" 30]

set message "Data loaded"


# ----------------------------------------------------
# Calculate diagram data
# ----------------------------------------------------


set sql "
	select	main_p.project_id as project_id,
		main_p.project_name as project_name,
		main_p.project_status_id,

		-- Presales Opportunities
		main_p.presales_value,
		main_p.presales_probability,

		-- Planned Hours
		(
			select	sum(coalesce(t.planned_units,0))
			from	im_projects p,
				im_timesheet_tasks t
			where	p.project_id = t.task_id and
				p.tree_sortkey between main_p.tree_sortkey and tree_right(main_p.tree_sortkey) and
				not exists (select project_id from im_projects leaf_p where leaf_p.parent_id = p.project_id)
		) as planned_hours,

		-- Value of planned hours
		round((
			select	sum(coalesce(planned_units, 0) * coalesce(sum_hourly_rate, :default_hourly_cost::float) / (coalesce(sum_percentage)+0.00000001))
			from	(
				select	planned_units,
					(
						select	sum(coalesce(bom.percentage, 100::numeric) * coalesce(e.hourly_cost, :default_hourly_cost::numeric))
						from	im_employees e,
							acs_rels r,
							im_biz_object_members bom
						where	r.object_id_one = p.project_id and
							r.object_id_two = e.employee_id and
							r.rel_id = bom.rel_id
					) as sum_hourly_rate,
					(
						select	sum(coalesce(bom.percentage, 100::numeric))
						from	acs_rels r,
							im_biz_object_members bom
						where	r.object_id_one = p.project_id and
							r.rel_id = bom.rel_id
					) as sum_percentage
					
				from	im_projects p,
					im_timesheet_tasks t
				where	p.project_id = t.task_id and
					p.tree_sortkey between main_p.tree_sortkey and tree_right(main_p.tree_sortkey) and
					not exists (select project_id from im_projects leaf_p where leaf_p.parent_id = p.project_id)
				) t
		)::numeric, 2) as planned_hours_value

	from	im_projects main_p
	where	main_p.parent_id is null and
		main_p.project_status_id not in ([im_project_status_deleted])
"

ad_return_complaint 1 [im_ad_hoc_query -format html $sql]


# ----------------------------------------------------
# Format and return the data
# ----------------------------------------------------

set json [im_sencha_sql_to_store -include_empty_p 0 -data_source_p 1 -sql $sql]
doc_return 200 "application/json" $json

