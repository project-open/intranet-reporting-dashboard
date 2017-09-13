-- /packages/intranet-reporting-dashboard/sql/oracle/intranet-reporting-dashboard-create.sql
--
-- ]project[ Dashboard Module
-- Copyright (c) 2003 - 2009 ]project-open[
--
-- All rights reserved. Please check
-- http://www.project-open.com/license/ for details.
-- @author frank.bergmann@project-open.com


---------------------------------------------------------
-- Dashboard page
--

create or replace function inline_0 ()
returns integer as '
declare
	v_menu			integer;
	v_main_menu 		integer;
	v_employees		integer;
BEGIN
	select group_id into v_employees from groups where group_name = ''Employees'';
	select menu_id into v_main_menu from im_menus where label=''main'';

	v_menu := im_menu__new (
		null,					-- p_menu_id
		''im_menu'',				-- object_type
		now(),					-- creation_date
		null,					-- creation_user
		null,					-- creation_ip
		null,					-- context_id
		''intranet-reporting-dashboard'',	-- package_name
		''dashboard'',				-- label
		''Dashboard'',				-- name
		''/intranet-reporting-dashboard/index'', -- url
		151,					-- sort_order
		v_main_menu,				-- parent_menu_id
		null					-- p_visible_tcl
	);

	PERFORM acs_permission__grant_permission(v_menu, v_employees, ''read'');

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();



----------------------------------------------------
-- Components
----------------------------------------------------


-- All Time Top Customers
--
-- SELECT im_component_plugin__new (
-- 	null,					-- plugin_id
-- 	'im_component_plugin',			-- object_type
-- 	now(),					-- creation_date
-- 	null,					-- creation_user
-- 	null,					-- creation_ip
-- 	null,					-- context_id
-- 	'Home All-Time Top Customers',		-- plugin_name
-- 	'intranet-reporting-dashboard',		-- package_name
-- 	'left',					-- location
-- 	'/intranet/index',			-- page_url
-- 	null,					-- view_name
-- 	100,					-- sort_order
-- 	'im_dashboard_all_time_top_customers_component',
-- 	'lang::message::lookup "" intranet-reporting-dashboard.All_Time_Top_Customers "All-Time Top Customers"'
-- );

-- All Time Top Customers
--
SELECT im_component_plugin__new (
	null,					-- plugin_id
	'im_component_plugin',			-- object_type
	now(),					-- creation_date
	null,					-- creation_user
	null,					-- creation_ip
	null,					-- context_id
	'Top Customers',			-- plugin_name
	'intranet-reporting-dashboard',		-- package_name
	'left',					-- location
	'/intranet/index',			-- page_url
	null,					-- view_name
	100,					-- sort_order
	'im_dashboard_top_customers -diagram_width 580 -diagram_height 300 -diagram_max_customers 8',
	'lang::message::lookup "" intranet-reporting-dashboard.Top_Customers "Top Customers"'
);







SELECT im_component_plugin__new (
	null, 'im_component_plugin', now(), null, null, null,	-- system params
	'Top Customers',					-- plugin_name
	'intranet-reporting-dashboard',				-- package_name
	'left',							-- location
	'/intranet/index',					-- page_url
	null,							-- view_name
	100,							-- sort_order
	'im_dashboard_top_customers -diagram_width 580 -diagram_height 300 -diagram_max_customers 8',
	'lang::message::lookup "" intranet-reporting-dashboard.Top_Customers "Top Customers"'
);
SELECT acs_permission__grant_permission(
	(select plugin_id from im_component_plugins where plugin_name = 'Top Customers' and page_url = '/intranet/index'),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);


SELECT im_component_plugin__new (
	null, 'im_component_plugin', now(), null, null, null,	-- system params
	'Top Customers (Company Dashboard)',			-- plugin_name
	'intranet-reporting-dashboard',				-- package_name
	'left',							-- location
	'/intranet/companies/dashboard',			-- page_url
	null,							-- view_name
	10,							-- sort_order
	'im_dashboard_top_customers -diagram_width 580 -diagram_height 300 -diagram_max_customers 8',
	'lang::message::lookup "" intranet-reporting-dashboard.Top_Customers "Top Customers"'
);
SELECT acs_permission__grant_permission(
	(select plugin_id from im_component_plugins 
	 where  plugin_name = 'Top Customers (Company Dashboard)' and 
	        page_url = '/intranet/companies/dashboard'),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);

SELECT im_component_plugin__new (
	null, 'im_component_plugin', now(), null, null, null,	-- system params
	'Top Customers (Finance Dashboard)',			-- plugin_name
	'intranet-reporting-dashboard',				-- package_name
	'left',							-- location
	'/intranet-invoices/dashboard',				-- page_url
	null,							-- view_name
	10,							-- sort_order
	'im_dashboard_top_customers -diagram_width 580 -diagram_height 300 -diagram_max_customers 8',
	'lang::message::lookup "" intranet-reporting-dashboard.Top_Customers "Top Customers"'
);
SELECT acs_permission__grant_permission(
	(select plugin_id from im_component_plugins 
	 where plugin_name = 'Top Customers (Finance Dashboard)' and 
		page_url = '/intranet-invoices/dashboard'
	),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);





-- All Time Top Services
--
-- SELECT im_component_plugin__new (
-- 	null,					-- plugin_id
-- 	'im_component_plugin',			-- object_type
-- 	now(),					-- creation_date
-- 	null,					-- creation_user
-- 	null,					-- creation_ip
-- 	null,					-- context_id
-- 	'Home All-Time Top Services',		-- plugin_name
-- 	'intranet-reporting-dashboard',		-- package_name
-- 	'left',					-- location
-- 	'/intranet/index',			-- page_url
-- 	null,					-- view_name
-- 	100,					-- sort_order
-- 	'im_dashboard_generic_component -component "generic" -left_vars "sub_project_type"',
-- 	'lang::message::lookup "" intranet-reporting-dashboard.All_Time_Top_Services "All-Time Top Services"'
-- );




-- Project Status Histogram
--
SELECT im_component_plugin__new (
	null,					-- plugin_id
	'im_component_plugin',			-- object_type
	now(),					-- creation_date
	null,					-- creation_user
	null,					-- creation_ip
	null,					-- context_id
	'Home Project Queue',			-- plugin_name
	'intranet-reporting-dashboard',		-- package_name
	'left',					-- location
	'/intranet/index',			-- page_url
	null,					-- view_name
	110,					-- sort_order
	'im_dashboard_active_projects_status_histogram',
	'lang::message::lookup "" intranet-reporting-dashboard.Project_Queue "Project Queue"'
);


-- Project Status Histogram
--
SELECT im_component_plugin__new (
        null,                                   -- plugin_id
        'im_component_plugin',                  -- object_type
        now(),                                  -- creation_date
        null,                                   -- creation_user
        null,                                   -- creation_ip
        null,                                   -- context_id
        'Project Queue',                        -- plugin_name
        'intranet-reporting-dashboard',         -- package_name
        'right',                                -- location
        '/intranet-cost/index',                 -- page_url
        null,                                   -- view_name
        40,                                     -- sort_order
        'im_dashboard_active_projects_status_histogram',
        'lang::message::lookup "" intranet-reporting-dashboard.Project_Queue "Project Queue"'
);


-- Tickets Histograms
--

SELECT im_component_plugin__new (
	null,					-- plugin_id
	'im_component_plugin',			-- object_type
	now(),					-- creation_date
	null,					-- creation_user
	null,					-- creation_ip
	null,					-- context_id
	'Ticket Status',			-- plugin_name
	'intranet-reporting-dashboard',		-- package_name
	'right',				-- location
	'/intranet-helpdesk/index',		-- page_url
	null,					-- view_name
	100,					-- sort_order
	'im_dashboard_histogram_sql -diagram_width 200 -name "Ticket per Ticket Status" -sql "
		select	im_category_from_id(ticket_status_id) as ticket_status,
		        count(*) as cnt
		from	im_tickets t
		where	t.ticket_status_id not in (select * from im_sub_categories(30097))
		group by ticket_status_id
		order by ticket_status
	"',
	'lang::message::lookup "" intranet-reporting-dashboard.Tickets_per_Ticket_Status "Status"'
);


SELECT im_component_plugin__new (
	null,					-- plugin_id
	'im_component_plugin',			-- object_type
	now(),					-- creation_date
	null,					-- creation_user
	null,					-- creation_ip
	null,					-- context_id
	'Ticket Type',				-- plugin_name
	'intranet-reporting-dashboard',		-- package_name
	'right',				-- location
	'/intranet-helpdesk/index',		-- page_url
	null,					-- view_name
	120,					-- sort_order
	'im_dashboard_histogram_sql -diagram_width 200 -name "Ticket per Ticket Type" -sql "
		select	im_category_from_id(ticket_type_id) as ticket_type,
		        count(*) as cnt
		from	im_tickets t
		where	t.ticket_status_id in (select * from im_sub_categories(30000))
		group by ticket_type_id
		order by ticket_type
	"',
	'lang::message::lookup "" intranet-reporting-dashboard.Tickets_per_Ticket_Type "Ticket Type"'
);



SELECT im_component_plugin__new (
	null,					-- plugin_id
	'im_component_plugin',			-- object_type
	now(),					-- creation_date
	null,					-- creation_user
	null,					-- creation_ip
	null,					-- context_id
	'Ticket Owner',				-- plugin_name
	'intranet-reporting-dashboard',		-- package_name
	'right',				-- location
	'/intranet-helpdesk/index',		-- page_url
	null,					-- view_name
	140,					-- sort_order
	'im_dashboard_histogram_sql -diagram_width 200 -name "Tickets per Ticket Owner" -sql "
		select	im_name_from_user_id(creation_user) as creation_user_name,
		        count(*) as cnt
		from	im_tickets t,
			acs_objects o
		where	t.ticket_id = o.object_id and
			t.ticket_status_id not in (select * from im_sub_categories(30097))
		group by creation_user
		order by creation_user_name
	"',
	'lang::message::lookup "" intranet-reporting-dashboard.Tickets_per_Ticket_Owner "Owner"'
);



-- Project Histograms
--

SELECT im_component_plugin__new (
	null,					-- plugin_id
	'im_component_plugin',			-- object_type
	now(),					-- creation_date
	null,					-- creation_user
	null,					-- creation_ip
	null,					-- context_id
	'Projects by Status',			-- plugin_name
	'intranet-reporting-dashboard',		-- package_name
	'right',				-- location
	'/intranet/projects/index',		-- page_url
	null,					-- view_name
	100,					-- sort_order
	'im_dashboard_histogram_sql -diagram_width 400 -sql "
		select	im_lang_lookup_category(''[ad_conn locale]'', p.project_status_id) as project_status,
		        count(*) as cnt
		from	im_projects p
		where	p.parent_id is null and
			p.project_status_id not in (select * from im_sub_categories(81))
		group by project_status_id
		order by project_status
	"',
	'lang::message::lookup "" intranet-reporting-dashboard.Sales_Pipeline "Sales Pipeline"'
);


SELECT im_component_plugin__new (
	null,					-- plugin_id
	'im_component_plugin',			-- object_type
	now(),					-- creation_date
	null,					-- creation_user
	null,					-- creation_ip
	null,					-- context_id
	'Pre-Sales Queue',			-- plugin_name
	'intranet-reporting-dashboard',		-- package_name
	'right',				-- location
	'/intranet/projects/index',		-- page_url
	null,					-- view_name
	100,					-- sort_order
	'im_dashboard_histogram_sql -diagram_width 400 -sql "
		select	im_lang_lookup_category(''[ad_conn locale]'', p.project_status_id) as project_status,
		        sum(coalesce(presales_probability,project_budget,0) * coalesce(presales_value,0)) as value
		from	im_projects p
		where	p.parent_id is null and
			p.project_status_id not in (select * from im_sub_categories(81))
		group by project_status_id
		order by project_status
	"',
	'lang::message::lookup "" intranet-reporting-dashboard.Sales_Pipeline "Sales<br>Pipeline"'
);










-- Absences per department
--
SELECT im_component_plugin__new (
	null, 'im_component_plugin', now(), null, null, null,
	'Users per Department',		    	-- plugin_name
	'intranet-reporting-dashboard',		-- package_name
	'left',					-- location
	'/intranet/users/dashboard',		-- page_url
	null,					-- view_name
	10,					-- sort_order
	'im_dashboard_histogram_sql -diagram_width 400 -sql "
	select	im_cost_center_code_from_id(cost_center_id) || '' - '' || im_cost_center_name_from_id(cost_center_id),
		round(coalesce(user_sum, 0.0), 1)
	from	(
		select	cost_center_id,
			tree_sortkey,
			(select count(*) from im_employees e where e.department_id = cc.cost_center_id) as user_sum
		from	im_cost_centers cc
		where	1 = 1
		) t
	where	user_sum > 0
	order by tree_sortkey
	"',
	'lang::message::lookup "" intranet-reporting-dashboard.Users_per_department "Users per Department"'
);
SELECT acs_permission__grant_permission(
	(select plugin_id from im_component_plugins 
	 where plugin_name = 'Users per Department'),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);











SELECT im_component_plugin__new (
	null, 'im_component_plugin', now(), null, null, null,
	'Pre-Sales Queue',			-- plugin_name
	'intranet-reporting-dashboard',		-- package_name
	'left',				-- location
	'/intranet/projects/dashboard',		-- page_url
	null,					-- view_name
	100,					-- sort_order
	'im_dashboard_histogram_sql -diagram_width 200 -sql "
		select	im_category_from_id(p.project_status_id) as project_status,
		        sum(coalesce(presales_probability,project_budget,0) * coalesce(presales_value,0)) as value
		from	im_projects p
		where	p.project_status_id not in (select * from im_sub_categories(81))
		group by project_status_id
		order by project_status
	"',
	'lang::message::lookup "" intranet-reporting-dashboard.Sales_Pipeline "Sales<br>Pipeline"'
);
SELECT acs_permission__grant_permission(
	(select plugin_id from im_component_plugins 
	 where plugin_name = 'Pre-Sales Queue' and 
		page_url = '/intranet/projects/dashboard'
	),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);








-- Absences per department
--
SELECT im_component_plugin__new (
	null, 'im_component_plugin', now(), null, null, null,
	'Average Absences Days per User',		-- plugin_name
	'intranet-reporting-dashboard',		-- package_name
	'left',					-- location
	'/intranet-timesheet2/absences/dashboard',	-- page_url
	null,					-- view_name
	10,					-- sort_order
	'im_dashboard_histogram_sql -diagram_width 400 -sql "
	select	im_cost_center_code_from_id(cost_center_id) || '' - '' || im_cost_center_name_from_id(cost_center_id),
		round(coalesce(1.0 * absence_sum / user_sum, 0.0), 1)
	from	(
		select	cost_center_id,
			tree_sortkey,
			(select count(*) from im_employees e where e.department_id = cc.cost_center_id
			) as user_sum,
			(select	sum(ua.duration_days)
			 from	im_user_absences ua,
			 	im_employees e
			 where	e.department_id = cc.cost_center_id and
			 	e.employee_id = ua.owner_id and
				ua.end_date > now()::date - 365
			) as absence_sum
		from	im_cost_centers cc
		where	1 = 1
		) t
	where	user_sum > 0
	order by tree_sortkey
	"',
	'lang::message::lookup "" intranet-reporting-dashboard.Average_absence_days_per_user_and_department "Average Absences Days per User"'
);
SELECT acs_permission__grant_permission(
	(select plugin_id from im_component_plugins 
	 where plugin_name = 'Average Absences Days per User'),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);





SELECT im_component_plugin__new (
	null,					-- plugin_id
	'im_component_plugin',			-- object_type
	now(),					-- creation_date
	null,					-- creation_user
	null,					-- creation_ip
	null,					-- context_id
	'30 Day Status Changes',		-- plugin_name
	'intranet-core',			-- package_name
	'right',				-- location
	'/intranet/projects/index',		-- page_url
	null,					-- view_name
	180,					-- sort_order
	'im_dashboard_status_matrix -max_category_len 3 -sql "
		select	count(*) as cnt,
			old_status_id,
			new_status_id
		from	(select	parent.project_status_id as new_status_id,
				max_audit_a.audit_object_status_id as old_status_id
			from	im_projects parent
				LEFT OUTER JOIN (
					select	p.project_id,
						max(a.audit_date) as max_audit_date
					from	im_projects p
						LEFT OUTER JOIN im_audits a ON (p.project_id = a.audit_object_id and a.audit_date < now() - ''30 days''::interval)
					where	p.parent_id is null
					group by p.project_id, p.project_status_id
				) max_audit_date ON (parent.project_id = max_audit_date.project_id)
				LEFT OUTER JOIN im_audits max_audit_a ON (max_audit_a.audit_object_id = parent.project_id and max_audit_a.audit_date = max_audit_date.max_audit_date)
			where	parent.parent_id is null
			) t
		group by old_status_id, new_status_id
	" -description "Shows how many projects have changed their status in the last 30 days.
	" -status_list [db_list status_list "select distinct project_status_id from im_projects order by project_status_id"]',
	'lang::message::lookup "" intranet-reporting-dashboard.Monthly_Project_Status_Changes "30 Day Status Changes"'
);
SELECT acs_permission__grant_permission(
	(select plugin_id from im_component_plugins where plugin_name = '30 Day Status Changes'),
	(select group_id from groups where group_name = 'Employees'), 
	'read'
);

