# /packages/intranet-hr/tcl/intranet-hr-procs.tcl
#
# Copyright (C) 2003-2004 Project/Open
#
# All rights reserved. Please check
# http://www.project-open.com/license/ for details.

ad_library {
    Common procedures for Dashboard
    @author frank.bergmann@project-open.com
}

# ----------------------------------------------------------------------
# Constant Functions
# ----------------------------------------------------------------------


ad_proc -public im_dashboard_status_id {} { return 450 }


# ----------------------------------------------------------------------
# Employee Info Component
# Some simple extension data for employeers
# ----------------------------------------------------------------------

ad_proc im_dashboard_info_component { dashboard_id return_url {view_name ""} } {
    Show some simple information about a dashboardr
} {
    if {"" == $view_name} { set view_name "dashboards_view" }
    ns_log Notice "im_dashboard_info_component: dashboard_id=$dashboard_id, view_name=$view_name"
    set current_user_id [ad_get_user_id]

    set date_format "YYYY-MM-DD"
    set number_format "9999990D99"

    set department_url "/intranet-cost/cost-centers/new?cost_center_id="
    set user_url "/intranet/users/view?user_id="

    set td_class(0) "class=roweven"
    set td_class(1) "class=rowodd"

    # dashboard_id gets modified by the SQl ... :-(
    set org_dashboard_id $dashboard_id    

    # --------------- Security --------------------------

    set view 0
    set read 0
    set write 0
    set admin 0
    im_user_permissions $current_user_id $dashboard_id view read write admin
    ns_log Notice "im_dashboard_info_component: view=$view, read=$read, write=$write, admin=$admin"
    if {!$read} { return "" }

    # Check if the current_user is a HR manager
    if {![im_permission $current_user_id view_hr]} { return "" }

    # Finally: Show this component only for dashboards
    if {![im_user_is_dashboard_p $dashboard_id]} { return "" }

    # --------------- Select all values --------------------------

    set dashboard_info_exists [db_0or1row dashboard_info "
	select	
		pe.first_names||' '||pe.last_name as user_name,
		p.email,
		e.*,
		rc.*,
		to_char(rc.start_date,:date_format) as start_date_formatted,
		to_char(rc.end_date,:date_format) as end_date_formatted,
		to_char(e.birthdate,:date_format) as birthdate_formatted,
		to_char(salary, :number_format) as salary_formatted,
		to_char(hourly_cost, :number_format) as hourly_cost_formatted,
		to_char(other_costs, :number_format) as other_costs_formatted,
		to_char(insurance, :number_format) as insurance_formatted,
		to_char(social_security, :number_format) as social_security_formatted,
		u.user_id,
		cc.cost_center_name as department_name,
		im_name_from_user_id(e.supervisor_id) as supervisor_name
	from	
		users u,
		im_dashboards e,
		im_repeating_costs rc,
		im_costs ci,
		parties p,
		persons pe,
		im_cost_centers cc
	where	
		pe.person_id = u.user_id
		and p.party_id = u.user_id
		and u.user_id = ci.cause_object_id
		and ci.cost_id = rc.rep_cost_id
		and u.user_id = :dashboard_id
		and u.user_id = e.dashboard_id
		and e.department_id = cc.cost_center_id
    "]

    set view_id [db_string get_view "select view_id from im_views where view_name=:view_name" -default 0]
    ns_log Notice "im_dashboard_info_component: view_id=$view_id"

    set column_sql "
	select	c.column_name,
		c.column_render_tcl,
		c.visible_for
	from	im_view_columns c
	where	c.view_id=:view_id
	order by sort_order"

   set dashboard_id $org_dashboard_id
   set dashboard_html "
	<form method=POST action=/intranet-hr/new>
	[export_form_vars dashboard_id return_url]
	<table cellpadding=1 cellspacing=1 border=0>
	<tr> 
	  <td colspan=2 class=rowtitle align=center>[_ intranet-hr.Dashboard_Information]</td>
	</tr>\n"

    set ctr 1
    if {$dashboard_info_exists} {
	# if the row makes references to "private Note" and the user isn't
	# adminstrator, this row don't appear in the browser.
	db_foreach column_list_sql $column_sql {
	    if {"" == $visible_for || [eval $visible_for]} {
		append dashboard_html "
                <tr $td_class([expr $ctr % 2])>
		<td>[_ "intranet-hr.[lang::util::suggest_key $column_name]"] &nbsp;</td><td>"
		set cmd "append dashboard_html $column_render_tcl"
		eval $cmd
		append dashboard_html "</td></tr>\n"
		incr ctr
	    }
	}
    } else {
	append dashboard_html "<tr><td colspan=2><i>[_ intranet-hr.Nothing_defined_yet]</i></tr></td>\n"
    }

    if {$admin } {
        append dashboard_html "
        <tr $td_class([expr $ctr % 2])>
        <td></td><td><input type=submit value='[_ intranet-hr.Edit]'></td></tr>\n"
    }
    append dashboard_html "</table></form>\n"

    return $dashboard_html
}
