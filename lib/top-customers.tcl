# /packages/intranet-reporting-dashboard/lib/top-customers.tcl
#
# Copyright (C) 2012 ]project-open[
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
if {![info exists diagram_max_customers]} { set diagram_max_customers 10 }
if {![info exists diagram_title]} { set diagram_title [lang::message::lookup "" intranet-reporting-dashboard.Top_Cusomers "Top Customers"] }

set max_length_customer_name 15


# ----------------------------------------------------
# Diagram Setup
# ----------------------------------------------------

# Create a random ID for the diagram
set diagram_rand [expr {round(rand() * 100000000.0)}]
set diagram_id "top_customers_$diagram_rand"

set default_currency [im_parameter -package_id [im_package_cost_id] "DefaultCurrency" "" "EUR"]

