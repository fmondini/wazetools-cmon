<%@ page
	language="java"
	contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="net.danisoft.dslib.*"
	import="net.danisoft.wazetools.cmon.*"
%>
	<div class="DS-padding-8px">
<%
	////////////////////////////////////////////////////////////////////////////////////////////////////
	//
	// NOTES POPUP SERVLET
	//

	Database DB = new Database();
	City CTY = new City(DB.getConnection());

	int CityID = EnvTool.getInt(request, "CityID", 0);

	try {

		City.Data ctyData = CTY.Read(CityID);

		if (ctyData.getNotes().trim().equals(""))
			throw new Exception("No notes found");
%>
		<div class="DS-text-fixed-compact"><%= ctyData.getNotes().replace("\n", "<br>") %></div>
<%
	} catch (Exception e) {
%>
		<div class="DS-text-exception">Unable to continue: <%= e.getMessage() %></div>
<%
	}

	DB.destroy();
%>
	</div>
