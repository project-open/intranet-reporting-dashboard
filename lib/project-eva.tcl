# /packages/intranet-reporting-dashboard/lib/project-eva.tcl
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
if {![info exists diagram_height]} { set diagram_height 400 }
if {![info exists diagram_title]} { set diagram_title [lang::message::lookup "" intranet-reporting-dashboard.Project_EVA "Project EVA"] }
if {![info exists diagram_project_id]} { 
    ad_return_complaint 1 "Project EVA: project_id required"
    ad_script_abort
}

# Create a random ID for the diagram
set diagram_rand [expr {round(rand() * 100000000.0)}]
set diagram_id "project_eva_$diagram_rand"
set default_currency [im_parameter -package_id [im_package_cost_id] "DefaultCurrency" "" "EUR"]


set axis_title_planned_ts_value_l10n [lang::message::lookup "" intranet-reporting-dashboard.Axis_Title_Planned_Ts_Value "Planned Value"]
set axis_title_total_planned_ts_value_l10n [lang::message::lookup "" intranet-reporting-dashboard.Axis_Title_Total_Planned_Ts_Value "Total Planned Value"]
set axis_title_date_l10n [lang::message::lookup "" intranet-reporting-dashboard.Axis_Title_Date "Date"]
set axis_title_timesheet_cost_l10n [lang::message::lookup "" intranet-reporting-dashboard.Axis_Title_Timesheet_Cost "Timesheet"]
set axis_title_invoices_l10n [lang::message::lookup "" intranet-reporting-dashboard.Axis_Title_Invoices "Invoices"]
set axis_title_quotes_l10n [lang::message::lookup "" intranet-reporting-dashboard.Axis_Title_Quotes "Quotes"]

set invoice_color "0000FF"
set quote_color "0020F0"



# ----------------------------------------------------------------------
# Calculate Diagram Parameters
# ---------------------------------------------------------------------

db_1row project_info "
	select	least(now(), main_p.start_date)::date as main_project_start_date,
		greatest(now(), main_p.end_date)::date as main_project_end_date
	from	im_projects main_p
	where	main_p.project_id = :diagram_project_id
"

# ad_return_complaint 1 "$main_project_start_date - $main_project_end_date"
