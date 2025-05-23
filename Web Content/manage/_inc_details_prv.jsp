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
	// PROVINCE SUMMARY SERVLET
	//

	Database DB = null;

	try {
		
		DB = new Database();

		String prvCode, prvDesc, divCode;
		String parentCode = EnvTool.getStr(request, "parentCode", "");

		Statement st = DB.getConnection().createStatement();

		ResultSet rs = st.executeQuery(
			"SELECT DISTINCT CTY_GeoRef AS Province, GEO_Name " +
			"FROM CMON_cities " +
			"LEFT JOIN " + GeoIso.getTblName() + " ON GEO_Code = CTY_GeoRef " +
			"WHERE LEFT(CTY_GeoRef, " + parentCode.length() + ") = '" + parentCode + "' " +
			"ORDER BY GEO_Name;"
		);
%>
		<table class="TableSpacing_0px DS-full-width">
<%
		while (rs.next()) {

			prvCode = rs.getString("Province");
			prvDesc = rs.getString("GEO_Name");
			divCode = prvCode.replace(":", "_").replace(".", "_");
%>
			<tr>
				<td id="TH_PRV_<%= divCode %>" class="DS-padding-0px DS-cursor-pointer" onclick="$('#TR_PRV_<%= divCode %>').toggle(); getCtyList('TD_PRV_<%= divCode %>', '<%= prvCode %>');" ColSpan="2">
					<div class="DS-text-large"><%= prvDesc %></div>
				</td>
			</tr>
			<tr id="TR_PRV_<%= divCode %>" style="display:none">
				<td class="DS-padding-0px" id="TD_PRV_<%= divCode %>" ColSpan="2">Wait...</td>
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
