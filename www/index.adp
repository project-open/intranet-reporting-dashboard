<master>
<property name="doc(title)">@page_title;literal@</property>
<property name="main_navbar_label">projects</property>
<property name="left_navbar">@left_navbar_html;literal@</property>

<h1><%=[lang::message::lookup "" intranet-reporting-dashboard.Dashboard "Dashboard"]%></h1>

<%= [im_component_bay top] %>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
<tr>
  <td valign="top" width='50%'>
      <%= [im_component_bay left] %>
  </td>
  <td width='5px'>&nbsp;</td>
  <td valign="top">
      <%= [im_component_bay right] %>
  </td>
</tr>
</table><br>

<table cellpadding="0" cellspacing="0" border="0" width="100%">
<tr><td>
  <!-- Bottom Component Bay -->
  <%= [im_component_bay bottom] %>
</td></tr>
</table>
