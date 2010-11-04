ad_page_contract {
    Calculate variables for main projects timeline
} {
    { return_url "" }
}



set main_projects_sql "
	select	p.*,
		to_char(p.start_date, 'YYYY-MM-DD') as start_date_iso,
		to_char(p.end_date, 'YYYY-MM-DD') as end_date_iso
	from	im_projects p
	where	p.parent_id is null and
		p.project_type_id not in ([im_project_type_task], [im_project_type_ticket])
"

set start_year [db_string start_year "select to_char(min(start_date), 'YYYY') from ($main_projects_sql) t" -default "2010"]

set start_date [db_string start_year "select to_char(min(start_date), 'YYYY-MM-DD') from ($main_projects_sql) t" -default "2010"]
set end_date [db_string start_year "select to_char(min(end_date), 'YYYY-MM-DD') from ($main_projects_sql) t" -default "2010"]

