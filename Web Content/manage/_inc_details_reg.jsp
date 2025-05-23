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
	// REGION SUMMARY SERVLET
	//

	Database DB = null;

	try {

		DB = new Database();

		String regCode, regDesc, divCode;

		String parentCode = EnvTool.getStr(request, "parentCode", "");
		String PrvDivToClick = EnvTool.getStr(request, "PrvDivToClick", "");

		Statement st = DB.getConnection().createStatement();

		ResultSet rs = st.executeQuery(
			"SELECT DISTINCT LEFT(CTY_GeoRef, 7) AS Region, GEO_Name " +
			"FROM CMON_cities " +
			"LEFT JOIN " + GeoIso.getTblName() + " ON GEO_Code = LEFT(CTY_GeoRef, 7) " +
			"WHERE LEFT(CTY_GeoRef, " + parentCode.length() + ") = '" + parentCode + "' " +
			"ORDER BY GEO_Name;"
		);
%>
		<table class="TableSpacing_0px DS-full-width">
<%
		while (rs.next()) {

			regCode = rs.getString("Region");
			regDesc = rs.getString("GEO_Name");
			divCode = regCode.replace(":", "_");
%>
			<tr>
				<td id="TH_REG_<%= divCode %>" class="DS-padding-0px DS-cursor-pointer" onclick="$('#TR_REG_<%= divCode %>').toggle(); getPrvList('TD_REG_<%= divCode %>', '<%= regCode %>', '<%= PrvDivToClick %>');" ColSpan="2">
					<div class="DS-text-huge"><%= regDesc %></div>
				</td>
			</tr>
			<tr id="TR_REG_<%= divCode %>" style="display:none">
				<td class="DS-padding-0px DS-border-lf" width="48">&nbsp;</td>
				<td class="DS-padding-0px" id="TD_REG_<%= divCode %>">Wait...</td>
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
