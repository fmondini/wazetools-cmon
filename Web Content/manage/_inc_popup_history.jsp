<%@ page
	language="java"
	contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="java.sql.*"
	import="java.util.*"
	import="net.danisoft.dslib.*"
	import="net.danisoft.wtlib.auth.*"
	import="net.danisoft.wtlib.cmon.*"
%>
<%!
	/**
	 * Retrieve modification log for a City ID
	 * 
	 * Log line example in LOG_Message field:
	 * <pre>City Edit (CTY_ID:3120) - Updated fields: - CTY_Editor '' -> 'giovanni-cortinovis'</pre>
	 */
	public Enumeration<Integer> getHistIDs(Connection cn, int CityID) throws Exception {
		
		Vector<Integer> Results = new Vector<>();

		Statement st = cn.createStatement();

		ResultSet rs = st.executeQuery(
			"SELECT LOG_ID " +
			"FROM " + LogTool.getTblName() + " " +
			"WHERE (" +
				"LOG_SourceApp = '" + LogTool.Category.CMON + "' AND " +
				"LOG_TextData LIKE '%(CTY_ID:" + CityID + ")%'" +
			") " +
			"ORDER BY LOG_Timestamp DESC"
		);

		while (rs.next())
			Results.addElement(rs.getInt("LOG_ID"));

		rs.close();
		st.close();

		return(Results.elements());
	}
%>
<%
	////////////////////////////////////////////////////////////////////////////////////////////////////
	//
	// HISTORY SUMMARY SERVLET
	//

	Database DB = new Database();
	User USR = new User(DB.getConnection());
	LogTool LOG = new LogTool(DB.getConnection());

	int LogID = 0;
	String LogDetails = "";

	int CityID = EnvTool.getInt(request, "CityID", 0);

	Enumeration<Integer> hstEnum = getHistIDs(DB.getConnection(), CityID);
%>
	<table class="TableSpacing_0px DS-full-width">
<%
	try {

		User.Data usrData = USR.Read(SysTool.getCurrentUser(request));

		boolean CanViewIP = usrData.getWazerConfig().getCmon().isEnabled(CmonRole.SYSADM);

		if (!hstEnum.hasMoreElements())
			throw new Exception("No history found");
%>
		<tr class="DS-back-gray DS-text-black">
			<td class="CellPadding_3px DS-border-updn DS-border-lfrg" nowrap align="center">Date / Time</td>
			<td class="CellPadding_3px DS-border-updn DS-border-rg"   nowrap align="center">Author</td>
			<td class="CellPadding_3px DS-border-updn DS-border-rg"   nowrap align="center">IP Address</td>
			<td class="CellPadding_3px DS-border-updn DS-border-rg"   nowrap align="center">Operation Log</td>
		</tr>
<%
		LogTool.Data logData;

		while (hstEnum.hasMoreElements()) {

			LogID = hstEnum.nextElement();

			logData = LOG.Read(LogID);

			LogDetails = logData.getTextData().replace("City Edit (CTY_ID:" + CityID + ") ", "");

			if (LogDetails.contains("]"))
				LogDetails = LogDetails.split("]")[1];

			LogDetails = LogDetails.replace("- Updated fields: - ", "");
			LogDetails = LogDetails.replace(" - ", "<br>");
%>
			<tr class="DS-text-compact">
				<td class="CellPadding_3px DS-border-dn DS-border-lfrg" nowrap valign="top" align="center"><%= FmtTool.fmtDateTime(logData.getTimestamp()) %></td>
				<td class="CellPadding_3px DS-border-dn DS-border-rg"   nowrap valign="top" align="left"  ><%= logData.getSourceUser() %></td>
				<td class="CellPadding_3px DS-border-dn DS-border-rg"   nowrap valign="top" align="center"><%= CanViewIP ? logData.getSourceIP() : "<span class='DS-text-italic DS-text-disabled'>[hidden]</span>" %></td>
				<td class="CellPadding_3px DS-border-dn DS-border-rg"          valign="top" align="left"  ><%= LogDetails %></td>
			</tr>
<%
		}

	} catch (Exception e) {
%>
		<tr class="DS-back-gray DS-border-updn DS-border-lfrg">
			<td colspan="4" class="CellPadding_3px" align="center">
				<div class="DS-text-exception">Unable to continue: <%= e.getMessage() %></div>
			</td>
		</tr>
<%
	}

	DB.destroy();
%>
	</table>
