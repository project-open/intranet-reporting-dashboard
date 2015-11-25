# /packages/intranet-reporting-dashboard/www/index.tcl
#
# Copyright (C) 2015 Project Open Business Solutions S.L.
#
# This program is free software. You can redistribute it
# and/or modify it under the terms of the GNU General
# Public License as published by the Free Software Foundation;
# either version 2 of the License, or (at your option)
# any later version. This program is distributed in the
# hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.

# @author mbryzek@arsdigita.com
# @author frank.bergmann@project-open.com 
# @author klaus.hofeditz@project-open.com


ad_page_contract {
    Dashboard main page  
} {
    { start_date "" }
    { end_date "" }
    { period "" }
}

# ---------------------------------------------------------------------
# Permissions
# ---------------------------------------------------------------------


# ---------------------------------------------------------------------
# Defaults & Security
# ---------------------------------------------------------------------
set show_context_help_p 0
set user_id [auth::require_login]
set return_url [im_url_with_query]
set current_url [ns_conn url]
set site_wide_admin_p [im_is_user_site_wide_or_intranet_admin $user_id]
set page_title ""
set left_navbar_html ""
set admin_html_content ""

db_1row todays_date "
	select
        	to_char(sysdate::date, 'YYYY') as todays_year,
        	to_char(sysdate::date, 'MM') as todays_month,
        	to_char(sysdate::date, 'DD') as todays_day
	from dual
"

# Show last 6 months by default 
if {"" == $end_date} { set end_date "$todays_year-$todays_month-01" }
if {"" == $start_date} { set start_date [clock format [clock scan {-6 months} -base [clock scan $end_date] ] -format %Y-%m-%d] }

if { "" == $period } {
    set period "month"
}

# ---------------------------------------------------------------------
# Validate
# ---------------------------------------------------------------------

if { "" != $start_date } {
    if {[catch {
        if { $start_date != [clock format [clock scan $start_date] -format %Y-%m-%d] } {
            ad_return_complaint 1 "<strong>[_ intranet-core.Start_Date]</strong> [lang::message::lookup "" intranet-core.IsNotaValidDate "is not a valid date"].<br>
            [lang::message::lookup "" intranet-core.Current_Value "Current value"]: '$start_date'<br>"
        }
    } err_msg]} {
        ad_return_complaint 1 "<strong>[_ intranet-core.Start_Date]</strong> [lang::message::lookup "" intranet-core.DoesNotHaveRightFormat "doesn't have the right format"].<br>
        [lang::message::lookup "" intranet-core.Current_Value "Current value"]: '$start_date'<br>
        [lang::message::lookup "" intranet-core.Expected_Format "Expected Format"]: 'YYYY-MM-DD'"
    }
}


if { "" != $end_date } {
    if {[catch {
        if { $end_date != [clock format [clock scan $end_date] -format %Y-%m-%d] } {
            ad_return_complaint 1 "<strong>[_ intranet-core.End_Date]</strong> [lang::message::lookup "" intranet-core.IsNotaValidDate "is not a valid date"].<br>
            [lang::message::lookup "" intranet-core.Current_Value "Current value"]: '$end_date'<br>"
        }
    } err_msg]} {
        ad_return_complaint 1 "<strong>[_ intranet-core.End_Date]</strong> [lang::message::lookup "" intranet-core.DoesNotHaveRightFormat "doesn't have the right format"].<br>
        [lang::message::lookup "" intranet-core.Current_Value "Current value"]: '$end_date'<br>
        [lang::message::lookup "" intranet-core.Expected_Format "Expected Format"]: 'YYYY-MM-DD'"
    }
}

# ---------------------------------------------------------------------
# Admin Box
# ---------------------------------------------------------------------

set sel_month ""
set sel_quarter ""
set sel_year ""
switch period {
    month { set sel_month selected }
    quarter { set sel_quarter selected }
    year { set sel_year selected }
}

set left_navbar_html "
        <form>
        <table border=0 cellspacing=1 cellpadding=1>
        <tr valign=top><td>
                <table border=0 cellspacing=1 cellpadding=1>
                <tr>
                  <td class=form-label>[lang::message::lookup "" intranet-core.Start_Date "Start Date"]</td>
                  <td class=form-widget>
                    <input type=textfield name=start_date value=$start_date>
                  </td>
                </tr>
                <tr>
                  <td class=form-label>[lang::message::lookup "" intranet-core.End_Date "End Date"]</td>
                  <td class=form-widget>
                    <input type=textfield name=end_date value=$end_date>
                  </td>
                </tr>
                <tr>
                  <td class=form-label>[lang::message::lookup "" intranet-reporting.Period "Period"]</td>
                  <td class=form-widget>
			 <select name='period'>
			   <option $sel_month value='month'>[lang::message::lookup "" acs-datetime.Month "Month"]</option>
			   <option $sel_quarter value='quarter'>[lang::message::lookup "" intranet-core.Quarter "Quarter"]</option>
			   <option $sel_year value='year'>[lang::message::lookup "" intranet-core.Year "Year"]</option>
			</select> 
                  </td>
                </tr>
                <tr>
                  <td class=form-label></td>
                  <td class=form-widget><input type=submit value='[lang::message::lookup "" acs-kernel.common_Submit "Submit"]'></td>
                </tr>
		</table>
	</tr>
	</table>
	</form>

"
