<%@ page
	language="java"
	contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="java.sql.*"
	import="net.danisoft.dslib.*"
	import="net.danisoft.wtlib.auth.*"
	import="net.danisoft.wazetools.cmon.*"
%>
<%!
	private static final String COLOR_ALPHA_VALUE = "0.10";
%>
<%
	////////////////////////////////////////////////////////////////////////////////////////////////////
	//
	// CITY SUMMARY SERVLET
	//

	Database DB = new Database();
	GeoIso GEO = new GeoIso(DB.getConnection());

	String parentCode = EnvTool.getStr(request, "parentCode", "");
	String nicknameFilter = EnvTool.getStr(request, "NicknameFilter", "");

	String WhereStm = nicknameFilter.equals("")
		? "LEFT(CTY_GeoRef, " + parentCode.length() + ") = '" + parentCode + "'"
		: "CTY_Editor LIKE '%" + nicknameFilter + "%'"
	;

	int AverageP = 0;
	String Query, normalizedCity, ExGeoRef = "";

	Statement st = DB.getConnection().createStatement();

	Query =
		"SELECT *, (" +
			"SELECT COUNT(*) " +
			"FROM WOTH_log " +
			"WHERE (" +
				"LOG_SourceApp = '" + AppList.CMON.getName() + "' AND " +
				"LOG_TextData LIKE CONCAT('%(CTY_ID:', CTY_ID, ')%') " +
			")" +
		") AS HistoryNo " +
		"FROM CMON_cities " +
		"WHERE (" + WhereStm + ") " +
		"ORDER BY " + (nicknameFilter.equals("") ? "" : "CTY_GeoRef, ") + "CTY_Name;"
	;

	ResultSet rs = st.executeQuery(Query);

%>
	<table class="TableSpacing_0px DS-full-width">

	<tr class="DS-back-gray DS-text-black DS-text-compact DS-text-italic DS-border-updn">
		<td nowrap class="DS-padding-2px DS-border-lfrg" align="center">City</td>
		<td nowrap class="DS-padding-2px DS-border-rg" align="center">Editors</td>
		<td nowrap class="DS-padding-2px DS-border-rg" align="center" width="55px">Street<br>Names</td>
		<td nowrap class="DS-padding-2px DS-border-rg" align="center" width="55px">Street<br>Numbers</td>
		<td nowrap class="DS-padding-2px DS-border-rg" align="center" width="55px">Gas<br>Stations</td>
		<td nowrap class="DS-padding-2px DS-border-rg" align="center" width="55px">Parking<br>Lots</td>
		<td nowrap class="DS-padding-2px DS-border-rg" align="center" width="55px">Land<br>Marks</td>
		<td nowrap class="DS-padding-2px DS-border-rg" align="center" width="55px">Nodes<br>Check</td>
		<td nowrap class="DS-padding-2px DS-border-rg" align="center" width="55px">Streets<br>Lock</td>
		<td nowrap class="DS-padding-2px DS-border-rg" align="center" colspan="3">Last Update</td>
	</tr>
<%
	while (rs.next()) {

		normalizedCity = rs.getString("CTY_Name").replace("'", "\\'");

		AverageP = (int) City.getCompletionPercent(
			rs.getInt("CTY_NodesCheckP"),
			rs.getInt("CTY_StreetNamesP"),
			rs.getInt("CTY_StreetNumbersP"),
			rs.getInt("CTY_GasStationsP"),
			rs.getInt("CTY_ParkingLotsP"),
			rs.getInt("CTY_LandmarksP"),
			rs.getInt("CTY_LockP")
		);

		if (!nicknameFilter.equals("") && !rs.getString("CTY_GeoRef").equals(ExGeoRef)) {
%>
			<tr class="DS-back-white">
				<td class="DS-padding-8px DS-border-lfrg DS-border-dn" ColSpan="14">
					<div class="DS-text-large">
						<span class="DS-text-bold DS-text-orange">&#128970;&nbsp;</span>
						<span class="DS-text-italic"><%= GEO.getFullDesc(rs.getString("CTY_GeoRef")) %></span>
					</div>
				</td>
			</tr>
<%			
		}
%>
		<tr class="DS-text-compact DS-border-dn">

			<td class="DS-padding-lfrg-4px DS-border-lfrg" style="background-color: rgba(<%= CmonColors.Hex2Rgb(CmonColors.getFill(AverageP)) %>,<%= COLOR_ALPHA_VALUE %>)" nowrap>
				<table class="TableSpacing_0px DS-full-width" style="color: <%= CmonColors.getStroke(AverageP) %>">
					<tr>
						<td align="left" nowrap><a href="edit.jsp?BackUrl=details.jsp&city=<%= rs.getInt("CTY_ID") %>&excity=<%= rs.getInt("CTY_ID") %>" style="<%= rs.getInt("CTY_Pop") > 15000 ? "font-weight: bold" : "" %>"><%= rs.getString("CTY_Name") %></a></td>
						<td align="right" nowrap><%= AverageP %>%</td>
					</tr>
				</table>
			</td>

			<td nowrap class="DS-padding-0px DS-border-rg" align="left">
				<table class="TableSpacing_0px DS-full-width"><tr>
					<td class="DS-padding-lfrg-4px DS-padding-updn-0px" align="left"><%= rs.getString("CTY_Editor").equals("")
						? "<span class='DS-text-disabled'>none</span>"
						: rs.getString("CTY_Editor").replace(SysTool.getCurrentUser(request), "<b>" + SysTool.getCurrentUser(request) + "</b>")
					%></td>
					<td class="DS-padding-lfrg-4px DS-padding-updn-0px" align="center" width="20px">
						<% if (rs.getInt("HistoryNo") == 0) { %>
							<div class="DS-padding-top-4px DS-padding-bottom-0px" title="No history found">
								<%= IcoTool.Symbol.RndExtn("history", true, "18px", 400, "LightGrey", "", "") %>
							</div>
						<% } else { %>
							<div class="DS-cursor-pointer DS-padding-top-4px DS-padding-bottom-0px" title="View History" onClick="getHistory('<%= rs.getInt("CTY_ID") %>', '<%= normalizedCity %>');">
								<%= IcoTool.Symbol.RndExtn("history", true, "18px", 700, "RoyalBlue", null, null) %>
							</div>
						<% } %>
					</td>
					<td class="DS-padding-lfrg-4px" align="center" width="20px">
						<% if (rs.getString("CTY_Notes").trim().equals("")) { %>
							<div class="DS-padding-top-4px DS-padding-bottom-0px" title="No notes attached">
								<%= IcoTool.Symbol.RndExtn("notes", true, "18px", 400, "LightGrey", "", "") %>
							</div>
						<% } else { %>
							<div class="DS-cursor-pointer DS-padding-top-4px DS-padding-bottom-0px" title="View Notes" onClick="getNotes('<%= rs.getInt("CTY_ID") %>', '<%= normalizedCity %>');">
								<%= IcoTool.Symbol.RndExtn("notes", true, "18px", 700, "RoyalBlue", null, null) %>
							</div>
						<% } %>
					</td>
				</tr></table>
			</td>

			<td nowrap class="DS-padding-lfrg-4px DS-padding-updn-0px DS-border-rg" align="center" style="background-color: rgba(<%= CmonColors.Hex2Rgb(CmonColors.getFill(rs.getInt("CTY_StreetNamesP"))) %>,<%= COLOR_ALPHA_VALUE %>)"><span style="color: <%= CmonColors.getStroke(rs.getInt("CTY_StreetNamesP")) %>"><%= rs.getInt("CTY_StreetNamesP") %>%</span></td>
			<td nowrap class="DS-padding-lfrg-4px DS-padding-updn-0px DS-border-rg" align="center" style="background-color: rgba(<%= CmonColors.Hex2Rgb(CmonColors.getFill(rs.getInt("CTY_StreetNumbersP"))) %>,<%= COLOR_ALPHA_VALUE %>)"><span style="color: <%= CmonColors.getStroke(rs.getInt("CTY_StreetNumbersP")) %>"><%= rs.getInt("CTY_StreetNumbersP") %>%</span></td>
			<td nowrap class="DS-padding-lfrg-4px DS-padding-updn-0px DS-border-rg" align="center" style="background-color: rgba(<%= CmonColors.Hex2Rgb(CmonColors.getFill(rs.getInt("CTY_GasStationsP"))) %>,<%= COLOR_ALPHA_VALUE %>)"><span style="color: <%= CmonColors.getStroke(rs.getInt("CTY_GasStationsP")) %>"><%= rs.getInt("CTY_GasStationsP") %>%</span></td>
			<td nowrap class="DS-padding-lfrg-4px DS-padding-updn-0px DS-border-rg" align="center" style="background-color: rgba(<%= CmonColors.Hex2Rgb(CmonColors.getFill(rs.getInt("CTY_ParkingLotsP"))) %>,<%= COLOR_ALPHA_VALUE %>)"><span style="color: <%= CmonColors.getStroke(rs.getInt("CTY_ParkingLotsP")) %>"><%= rs.getInt("CTY_ParkingLotsP") %>%</span></td>
			<td nowrap class="DS-padding-lfrg-4px DS-padding-updn-0px DS-border-rg" align="center" style="background-color: rgba(<%= CmonColors.Hex2Rgb(CmonColors.getFill(rs.getInt("CTY_LandmarksP"))) %>,<%= COLOR_ALPHA_VALUE %>)"><span style="color: <%= CmonColors.getStroke(rs.getInt("CTY_LandmarksP")) %>"><%= rs.getInt("CTY_LandmarksP") %>%</span></td>
			<td nowrap class="DS-padding-lfrg-4px DS-padding-updn-0px DS-border-rg" align="center" style="background-color: rgba(<%= CmonColors.Hex2Rgb(CmonColors.getFill(rs.getInt("CTY_NodesCheckP"))) %>,<%= COLOR_ALPHA_VALUE %>)"><span style="color: <%= CmonColors.getStroke(rs.getInt("CTY_NodesCheckP")) %>"><%= rs.getInt("CTY_NodesCheckP") %>%</span></td>
			<td nowrap class="DS-padding-lfrg-4px DS-padding-updn-0px DS-border-rg" align="center" style="background-color: rgba(<%= CmonColors.Hex2Rgb(CmonColors.getFill(rs.getInt("CTY_LockP"))) %>,<%= COLOR_ALPHA_VALUE %>)"><span style="color: <%= CmonColors.getStroke(rs.getInt("CTY_LockP")) %>"><%= rs.getInt("CTY_LockP") %>%</span></td>

			<td nowrap class="DS-padding-updn-0px" align="right"><%= rs.getString("CTY_LastUpdatedBy").equals("") || rs.getString("CTY_LastUpdatedBy").contains("system")
				? "<span class=\"DS-text-gray\">" + FmtTool.fmtDateTime(rs.getTimestamp("CTY_LastUpdated")) + "</span>"
				: "<span class=\"DS-text-black\">" + FmtTool.fmtDateTime(rs.getTimestamp("CTY_LastUpdated")) + "</span>"
			%></td>
			<td nowrap class="DS-padding-updn-0px" align="center"><span class="DS-text-gray">by</span></td>
			<td nowrap class="DS-padding-0px DS-border-rg" align="left"><%= rs.getString("CTY_LastUpdatedBy").equals("") || rs.getString("CTY_LastUpdatedBy").contains("system")
				? "<span class=\"DS-text-gray\">Sys/Op</span>"
				: "<span class=\"DS-text-black\">" + rs.getString("CTY_LastUpdatedBy") + "</span>"
			%></td>

		</tr>
<%
		ExGeoRef = rs.getString("CTY_GeoRef");
	}

	DB.destroy();
%>
	</table>
