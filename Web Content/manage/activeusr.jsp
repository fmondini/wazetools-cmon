<%@ page
	language="java"
	contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="java.sql.*"
	import="net.danisoft.dslib.*"
	import="net.danisoft.wtlib.auth.*"
	import="net.danisoft.wtlib.cmon.*"
	import="net.danisoft.wazetools.*"
%>
<%!
	private static final String PAGE_Title = "List of Active Users";
	private static final String PAGE_Keywords = "";
	private static final String PAGE_Description = "";

	private static final CmonRole requiredRole = CmonRole.ACTIVEUSR;
%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="../_common/head.jsp">
		<jsp:param name="PAGE_Title" value="<%= PAGE_Title %>"/>
		<jsp:param name="PAGE_Keywords" value="<%= PAGE_Keywords %>"/>
		<jsp:param name="PAGE_Description" value="<%= PAGE_Description %>"/>
	</jsp:include>
</head>

<body>

	<jsp:include page="../_common/header.jsp" />

	<div class="mdc-layout-grid DS-layout-body">
	<div class="mdc-layout-grid__inner">

	<div class="<%= MdcTool.Layout.Cell(12, 8, 4) %>">

	<div class="DS-card-body">
		<div class="DS-text-title-shadow">Active <%= AppCfg.getAppName() %> Users</div>
	</div>
<%
	String RedirectTo = "";

	Database DB = new Database();
	User USR = new User(DB.getConnection());
	LogTool LOG = new LogTool(DB.getConnection());
	MsgTool MSG = new MsgTool(session);

	User.Data usrData = USR.Read(SysTool.getCurrentUser(request));

	if (usrData.getWazerConfig().getCmon().isEnabled(requiredRole)) {

		try {

			Statement st = DB.getConnection().createStatement();

			ResultSet rs = st.executeQuery(
				"SELECT MAX(LOG_Timestamp) AS MaxDate, MIN(LOG_Timestamp) AS MinDate, LOG_SourceUser, USR_Mail, CMON_UserRole " +
				"FROM WOTH_log " +
				"LEFT JOIN AUTH_users ON LOG_SourceUser = USR_Name " +
				"WHERE LOG_SourceApp = '" + LogTool.Category.CMON.getCode() + "' AND NOT ISNULL(USR_Mail) AND NOT ISNULL(CMON_UserRole) " +
				"GROUP BY LOG_SourceUser " +
				"ORDER BY MaxDate DESC"
			);
%>
			<div class="DS-padding-updn-4px">
			<table class="TableSpacing_0px DS-full-width">

			<tr class="DS-text-compact DS-text-black DS-text-bold DS-text-italic DS-back-gray DS-border-full">
				<td class="DS-padding-4px DS-border-rg" align="center" colspan="2">Last Login</td>
				<td class="DS-padding-4px DS-border-rg" align="center">User ID</td>
				<td class="DS-padding-4px DS-border-rg" align="center">User Mail</td>
				<td class="DS-padding-4px DS-border-rg" align="center">Privileges</td>
				<td class="DS-padding-4px DS-border-rg" align="center">First Time Seen</td>
			</tr>
<%
			int UsrAuth = 0, UserCount = 0;
			String AuthString = "", LogTime = "", LogDate = "", ExLogDate = "";

			while (rs.next()) {

				if (!rs.getString("LOG_SourceUser").equals("fmondini")) { // Skip me

					AuthString = "";
					UsrAuth = rs.getInt("CMON_UserRole");

					for (CmonRole X : CmonRole.values())
						if ((UsrAuth & X.getValue()) == X.getValue())
							AuthString += X.getDescr() + ", ";

					AuthString = AuthString.concat("&nbsp;").replace(", &nbsp;", "");

					LogDate = FmtTool.fmtDate(rs.getTimestamp("MaxDate"));
					LogTime = FmtTool.fmtTime(rs.getTimestamp("MaxDate"));

					if (!LogDate.equals(ExLogDate) & !ExLogDate.equals("")) {
%>
					<tr class="DS-border-dn">
						<td class="DS-padding-2px DS-back-AliceBlue DS-border-lfrg" colspan="6"></td>
					</tr>
<%
					}
%>
					<tr class="DS-border-dn DS-text-small">
						<td class="DS-padding-updn-0px DS-padding-lf-2px DS-text-fixed-small DS-border-lf" nowrap align="left" valign="top"><%= LogDate.equals(ExLogDate) ? "&nbsp;" : LogDate %></td>
						<td class="DS-padding-updn-0px DS-padding-rg-2px DS-text-fixed-small DS-border-rg" nowrap align="right" valign="top"><%= LogTime %></td>
						<td class="DS-padding-updn-0px DS-padding-lfrg-2px DS-border-rg" nowrap valign="top"><%= rs.getString("LOG_SourceUser") %></td>
						<td class="DS-padding-updn-0px DS-padding-lfrg-2px DS-border-rg" nowrap valign="top"><%= rs.getString("USR_Mail") %></td>
						<td class="DS-padding-updn-0px DS-padding-lfrg-2px DS-border-rg" valign="top"><%= AuthString %></td>
						<td class="DS-padding-updn-0px DS-padding-lfrg-2px DS-text-fixed-small DS-border-rg" nowrap valign="top"><%= FmtTool.fmtDateTime(rs.getTimestamp("MinDate")) %></td>
					</tr>
<%
					UserCount++;
					ExLogDate = LogDate;
				}
			}
%>
			<tr>
				<td class="DS-padding-8px DS-back-lightgray DS-border-dn DS-border-lfrg" ColSpan="6" align="center">
					<div class="DS-text-big DS-text-gray DS-text-italic">Total Active Users: <b><%= UserCount %></b></div>
				</td>
			</tr>

			</table>
			</div>
<%
			rs.close();
			st.close();

		} catch (Exception e) {

			System.err.println(e.toString());
			MSG.setAlertText("Internal Error", e.toString());
			LOG.Error(request, LogTool.Category.CMON, "Internal Error - " + e.toString());

			RedirectTo = "../home/";
		}

	} else {

		String AlertText = "Sorry, a permission of type '" + requiredRole.getDescr() + "' is <b>required</b> to view this list";

		System.err.println(AlertText);
		MSG.setAlertText("Insufficient Authorization", AlertText);
		if (LOG != null)
			LOG.Error(request, LogTool.Category.CMON, "Active Users List - Insufficient Authorization");

		RedirectTo = "stats.jsp";
	}

	DB.destroy();
%>
	<div class="DS-card-foot">
		<%= MdcTool.Button.BackTextIcon("Back", "../home/") %>
	</div>

	</div>
	</div>
	</div>

	<jsp:include page="../_common/footer.jsp">
		<jsp:param name="RedirectTo" value="<%= RedirectTo %>"/>
	</jsp:include>

</body>
</html>
