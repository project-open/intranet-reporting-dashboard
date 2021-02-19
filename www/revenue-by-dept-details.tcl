# /packages/intranet-reporting-dashboard/revenue-by-dept-details.tcl
#
# Copyright (c) 2003-2019 ]project-open[
#
# All rights reserved. 
# Please see https://www.project-open.com/ for licensing.

ad_page_contract {
    Lists risks per project, taking into account DynFields.
} {
    date
    dept
    dept_sql
    { level_of_detail 3 }
    { output_format "html" }
    { number_locale "" }
}

# ad_return_complaint 1 "<pre>$dept_sql</pre>"

# ------------------------------------------------------------
# Security
#
set current_user_id [ad_conn user_id]
if {![im_permission $current_user_id view_companies_all] || ![im_permission $current_user_id view_finance]} { 
    set message "You don't have the necessary permissions to view this page"
    ad_return_complaint 1 "<li>$message"
    ad_script_abort
}

set menu_label "revenue-by-dept-details"

# ------------------------------------------------------------
# Check Parameters
#

# Maxlevel is 3. 
if {$level_of_detail > 3} { set level_of_detail 3 }

# Default is user locale
if {"" == $number_locale} { set number_locale [lang::user::locale] }



# ------------------------------------------------------------
# Page Title, Bread Crums and Help
#
set page_title [lang::message::lookup "" intranet-reporting-dashboard.Revenue_by_Dept_Details "Revenue by Department - Details"]
set context_bar [im_context_bar $page_title]
set help_text "
	<strong>$page_title:</strong><br>
	[lang::message::lookup "" intranet-riskmanagement.Project_Risks_help "
	This report shows details of 'Revenue by Dept' indicator and how it
        has been calculated.<br>
	It contains a list of all projects ongoing during the selected month
	and shows revenues and profit on the 1st of the selected month vs.
        the 1st of the previous month. The difference between the two is the
	revenue/profit generated during this month.<br>
	The total at the bottom of the page should show exactly the same
	value as the selected point in the 'Revenues by Dept' indicator.

"]"


# ------------------------------------------------------------
# Default Values and Constants
#
set rowclass(0) "roweven"
set rowclass(1) "rowodd"

# Variable formatting - Default formatting is quite ugly
# normally. In the future we will include locale specific
# formatting. 
#
set currency_format "999,999,999.09"
set percentage_format "90.9"
set date_format "YYYY-MM-DD"

# Set URLs on how to get to other parts of the system for convenience.
set company_url "/intranet/companies/view?company_id="
set project_url "/intranet/projects/view?project_id="
set risk_url "/intranet-riskmanagement/new?form_mode=display&risk_id="
set user_url "/intranet/users/view?user_id="
set this_url "[export_vars -base "/intranet-riskmanagement/project-risks-report" {} ]?"

# Level of Details
# Determines the LoD of the grouping to be displayed
#
set levels [list \
    2 [lang::message::lookup "" intranet-riskmanagement.Risks_per_Project "Risks per Project"] \
    3 [lang::message::lookup "" intranet-riskmanagement.All_Details "All Details"] \
]


# ------------------------------------------------------------
# Report SQL
#

# The previous month - start of the reporting period
set prev [db_string prev "select (:date::date - '1 month'::interval)::date"]



set report_sql "
	select	main_p.project_id,
		main_p.project_name,
		main_p.department,

		main_p.start_date, 
		main_p.end_date,

		main_p.start_date::date as start_date_pretty,
		main_p.end_date::date as end_date_pretty,

		im_category_from_id(main_p.project_type_id) as project_type,
		im_category_from_id(main_p.project_status_id) as project_status,

		revenue,
		internal_cost,
		external_cost,
		profit,

		round(revenue * date_percent / 100.0, 2) as date_revenue,
		round(external_cost * date_percent / 100.0, 2) as date_external_cost,
		round(internal_cost * date_percent / 100.0, 2)  as date_internal_cost,
		round(profit * date_percent / 100.0, 2) as date_profit,

		round(revenue * prev_percent / 100.0, 2) as prev_revenue,
		round(external_cost * prev_percent / 100.0, 2)  as prev_external_cost,
		round(internal_cost * prev_percent / 100.0, 2)  as prev_internal_cost,
		round(profit * prev_percent / 100.0, 2) as prev_profit,

		round(revenue / 100.0 * (date_percent - prev_percent), 2) as revenue_in_interval,
		round(profit / 100.0 * (date_percent - prev_percent), 2) as profit_in_interval

	from
		(select	*,
			round(CASE
				WHEN (:date::date - end_date) > 0 THEN 100.0			-- project finished
				WHEN (:date::date - start_date) < 0 THEN 0.0			-- not yet started
				ELSE 100.0 * (:date::date - start_date) / (greatest(1, end_date -  start_date))	-- in course
			END,2) as date_percent,
			round(CASE
				WHEN (:prev::date - end_date) > 0 THEN 100.0			-- project finished
				WHEN (:prev::date - start_date) < 0 THEN 0.0			-- not yet started
				ELSE 100.0 * (:prev::date - start_date) / (greatest(1, end_date -  start_date))	-- in course
			END,2) as prev_percent,
			(revenue - internal_cost - external_cost) as profit

		from	(
				select	project_id,
					project_name,
					$dept_sql as department,
					start_date::date as start_date,
					greatest(end_date::date, start_date::date + (cost_invoices_cache/5000)::integer) as end_date,
					project_status_id,
					project_type_id,
					coalesce(cost_invoices_cache, 0.0) as revenue,
					coalesce(cost_bills_cache, 0.0) as external_cost,
					coalesce(cost_timesheet_logged_cache, 0.0) + coalesce(cost_expense_logged_cache, 0.0) as internal_cost
				from	im_projects
				where	parent_id is null and
					start_date is not null and
					project_status_id not in ([im_project_status_deleted]) and
					end_date >= :prev::date and
					start_date < :date::date
			) p
		) main_p
	where
		('Total' = :dept OR department = :dept) and
		(revenue > 0 OR external_cost > 0 OR internal_cost > 0)
	order by
		revenue DESC
"
# ad_return_complaint 1 [im_ad_hoc_query -format html $report_sql]

# ------------------------------------------------------------
# Report Definition
#

# Global Header
set header0 [list \
	"Project" \
	"Department" \
	"Start" \
	"End" \
	"Type" \
	"Status" \
	"Revenue" \
	"Internal Costs" \
	"External Costs" \
	"Profit" \
	"Revenue<br>($prev)" \
	"Revenue<br>($date)" \
	"Revenue<br>(in interval)" \
	"Profit<br>($prev)" \
	"Profit<br>($date)" \
	"Profit<br>(in interval)" \
]

# Main content line
set header_vars {
	"<nobr><a href=$project_url$project_id>$project_name</a></nobr>"
	"<nobr>$department</nobr>"
	"<nobr>$start_date_pretty</nobr>"
	"<nobr>$end_date_pretty</nobr>"
	"<nobr>$project_type</nobr>"
	"<nobr>$project_status</nobr>"
	"#align=right [im_report_format_number $revenue $output_format $number_locale]"
	"#align=right [im_report_format_number $internal_cost $output_format $number_locale]"
	"#align=right [im_report_format_number $external_cost $output_format $number_locale]"
	"#align=right [im_report_format_number $profit $output_format $number_locale]"

	"#align=right [im_report_format_number $prev_revenue $output_format $number_locale]"
	"#align=right [im_report_format_number $date_revenue $output_format $number_locale]"
	"#align=right <b>[im_report_format_number $revenue_in_interval $output_format $number_locale]</b>"

	"#align=right [im_report_format_number $prev_profit $output_format $number_locale]"
	"#align=right [im_report_format_number $date_profit $output_format $number_locale]"
	"#align=right <b>[im_report_format_number $profit_in_interval $output_format $number_locale]</b>"
}


# The entries in this list include <a HREF=...> tags
# in order to link the entries to the rest of the system (New!)
#
set report_def [list \
    group_by project_id \
    header $header_vars \
    content [list ] \
    footer {} \
]

# Global Footer Line
set footer0 {"" "" "" "" "" "" "" "" "" "" 
    "" "" "#align=right <b>[im_report_format_number [expr round(100.0 * $revenue_total) / 100.0] $output_format $number_locale]</b>" 
    "" "" "#align=right <b>[im_report_format_number [expr round(100.0 * $profit_total) / 100.0] $output_format $number_locale]</b>" 
}


# ------------------------------------------------------------
# Counters
#

#
# Subtotal Counters (per project)
#
set revenue_counter [list \
	pretty_name "Revenue" \
	var revenue_total \
	reset 0 \
	expr "\$revenue_in_interval+0" \
]

set profit_counter [list \
	pretty_name "Profit" \
	var profit_total \
	reset 0 \
	expr "\$profit_in_interval+0" \
]


set counters [list \
	$revenue_counter \
	$profit_counter \
]


# Set the values to 0 as default (New!)
set revenue_total 0.0
set profit_total 0


# ------------------------------------------------------------
# Start Formatting the HTML Page Contents
#
im_report_write_http_headers -report_name $menu_label -output_format $output_format

switch $output_format {
    html {
	ns_write "
	[im_header]
	[im_navbar reporting]
	<table cellspacing=0 cellpadding=0 border=0>
	<tr valign=top>
	  <td width='30%'>
		<!-- 'Filters' - Show the Report parameters -->
		<form>
		<table cellspacing=2>
		<tr class=rowtitle>
		  <td class=rowtitle colspan=2 align=center>Filters</td>
		</tr>
		<tr>
		  <td>Level of<br>Details</td>
		  <td>
		    [im_select -translate_p 0 level_of_detail $levels $level_of_detail]
		  </td>
		</tr>
		<tr>
		  <td class=form-label>[lang::message::lookup "" intranet-reporting.Output_Format Format]</td>
		  <td class=form-widget>
		    [im_report_output_format_select output_format "" $output_format]
		  </td>
		</tr>
		<tr>
		  <td class=form-label><nobr>[lang::message::lookup "" intranet-reporting.Number_Format "Number Format"]</nobr></td>
		  <td class=form-widget>
		    [im_report_number_locale_select number_locale $number_locale]
		  </td>
		</tr>
		<tr>
		  <td</td>
		  <td><input type=submit value='Submit'></td>
		</tr>
		</table>
		</form>
	  </td>
	  <td align=center>
		<table cellspacing=2 width='90%'>
		<tr>
		  <td>$help_text</td>
		</tr>
		</table>
	  </td>
	</tr>
	</table>
	
	<!-- Here starts the main report table -->
	<table border=0 cellspacing=1 cellpadding=1>
    "
    }
}

set footer_array_list [list]
set last_value_list [list]

im_report_render_row \
    -output_format $output_format \
    -row $header0 \
    -row_class "rowtitle" \
    -cell_class "rowtitle"

set counter 0
set class ""
db_foreach sql $report_sql {
	set class $rowclass([expr {$counter % 2}])

	# Restrict the length of the project_name to max. 40 characters.
	set project_name [string_truncate -len 40 $project_name]

	im_report_display_footer \
	    -output_format $output_format \
	    -group_def $report_def \
	    -footer_array_list $footer_array_list \
	    -last_value_array_list $last_value_list \
	    -level_of_detail $level_of_detail \
	    -row_class $class \
	    -cell_class $class

	im_report_update_counters -counters $counters

	set last_value_list [im_report_render_header \
	    -output_format $output_format \
	    -group_def $report_def \
	    -last_value_array_list $last_value_list \
	    -level_of_detail $level_of_detail \
	    -row_class $class \
	    -cell_class $class
	]

	set footer_array_list [im_report_render_footer \
	    -output_format $output_format \
	    -group_def $report_def \
	    -last_value_array_list $last_value_list \
	    -level_of_detail $level_of_detail \
	    -row_class $class \
	    -cell_class $class
	]

	incr counter
}

im_report_display_footer \
    -output_format $output_format \
    -group_def $report_def \
    -footer_array_list $footer_array_list \
    -last_value_array_list $last_value_list \
    -level_of_detail $level_of_detail \
    -display_all_footers_p 1 \
    -row_class $class \
    -cell_class $class

im_report_render_row \
    -output_format $output_format \
    -row $footer0 \
    -row_class $class \
    -cell_class $class \
    -upvar_level 1


# Write out the HTMl to close the main report table
#
switch $output_format {
    html {
	ns_write "</table>\n"
	ns_write "<br>&nbsp;<br>"
	ns_write [im_footer]
    }
}

