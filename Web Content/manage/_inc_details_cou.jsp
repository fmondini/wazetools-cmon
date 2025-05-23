<%@ page
	language="java"
	contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="java.sql.*"
	import="net.danisoft.dslib.*"
	import="net.danisoft.wtlib.auth.*"
%>
<%
	////////////////////////////////////////////////////////////////////////////////////////////////////
	//
	// COUNTRY SUMMARY SERVLET
	//

	Database DB = null;

	try {
		
		DB = new Database();

		String couCode, couDesc, divCode;

		String RegDivToClick = EnvTool.getStr(request, "RegDivToClick", "");
		String PrvDivToClick = EnvTool.getStr(request, "PrvDivToClick", "");

		Statement st = DB.getConnection().createStatement();

		ResultSet rs = st.executeQuery(
			"SELECT DISTINCT LEFT(CTY_GeoRef, 3) AS Country, GEO_Name " +
			"FROM CMON_cities " +
			"LEFT JOIN " + GeoIso.getTblName() + " ON GEO_Code = LEFT(CTY_GeoRef, 3) " +
			"ORDER BY GEO_Name;"
		);
%>
		<table class="TableSpacing_0px DS-full-width">
<%
		while (rs.next()) {

			couCode = rs.getString("Country");
			couDesc = rs.getString("GEO_Name");
			divCode = couCode;
%>
			<tr>
				<td id="TH_COU_<%= divCode %>" class="DS-padding-0px DS-cursor-pointer" onclick="$('#TR_COU_<%= divCode %>').toggle(); getRegList('TD_COU_<%= divCode %>', '<%= couCode %>', '<%= RegDivToClick %>', '<%= PrvDivToClick %>');" ColSpan="2">
					<div class="DS-text-extra-large"><%= couDesc %></div>
				</td>
			</tr>
			<tr id="TR_COU_<%= divCode %>" style="display:none">
				<td class="DS-padding-0px DS-border-lf" width="48">&nbsp;</td>
				<td class="DS-padding-0px" id="TD_COU_<%= divCode %>">Wait...</td>
			</tr>
<%
		}

	} catch (Exception e) {
		System.err.println(e.toString());
	}

	if (DB != null)
		DB.destroy();
%>
	</table>
