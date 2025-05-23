<%@ page
	language="java"
	contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="java.net.*"
	import="java.util.*"
	import="java.nio.file.attribute.*"
	import="org.apache.poi.ss.usermodel.*"
	import="org.apache.poi.hssf.usermodel.*"
	import="net.danisoft.dslib.*"
	import="net.danisoft.wazetools.*"
	import="net.danisoft.wazetools.cmon.*"
%>
<%!
	private static final String PAGE_Title = "Export Your Data";
	private static final String PAGE_Keywords = "";
	private static final String PAGE_Description = "";
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
<%
	String RedirectTo = "";

	Database DB = new Database();
	MsgTool MSG = new MsgTool(session);

	String Action = EnvTool.getStr(request, "Action", "");
%>
	<jsp:include page="../_common/header.jsp" />

	<div class="mdc-layout-grid DS-layout-body">
	<div class="mdc-layout-grid__inner">
	<div class="<%= MdcTool.Layout.Cell(12, 8, 4) %>">
<%
	try {

		if (Action.equals("")) {
%>
		<div class="DS-card-head">
			<div class="DS-text-title-shadow">Export your data in Excel&trade; format</div>
		</div>

		<div class="DS-card-body">
			<div class="DS-text-justified">With this tool you can export all your data in a Micro$oft&trade; Excel&trade; compatible format.</div>
		</div>

		<div class="DS-card-body">
			<div class="DS-text-huge">How-to download data</div>
		</div>

		<div class="DS-card-foot">
			<div class="DS-text-justified">Just hit the [Download] button below... &#128514;</div>
		</div>

		<div class="DS-card-foot">
			<div class="mdc-layout-grid__inner">
				<div class="<%= MdcTool.Layout.Cell(6, 4, 2) %>" align="left">
					<%= MdcTool.Button.BackTextIcon("Back", "../manage/") %>
				</div>
				<div class="<%= MdcTool.Layout.Cell(6, 4, 2) %>" align="right">
					<%= MdcTool.Button.TextIcon(
						"download",
						"&nbsp;Download",
						null,
						"onClick=\"window.location.href='?Action=create'\"",
						"Clicl here to download your data"
					) %>
				</div>
			</div>
		</div>
<%
		} else if (Action.equals("create")) {
%>
			<div class="DS-card-head">
				<div class="DS-text-huge">Exporting data in Excel&trade; format</div>
			</div>

			<div class="DS-card-foot">
				<div class="DS-text-justified">Running, please wait...</div>
			</div>
<%
			String FieldList[][] = {
			//	-----------------------------------	-----------------------	------------------
			//	FIELD TYPE							FIELD NAME				COLUMN DESCR
			//	-----------------------------------	-----------------------	------------------
				{ ExpTool.FieldType.STR.getValue(),	"GEO_Code",				"Location" },
				{ ExpTool.FieldType.STR.getValue(),	"CTY_Name",				"City" },
				{ ExpTool.FieldType.STR.getValue(),	"CTY_Editor",			"Editor" },
				{ ExpTool.FieldType.DBL.getValue(),	"CTY_Lat",				"Lat" },
				{ ExpTool.FieldType.DBL.getValue(),	"CTY_Lng",				"Lon" },
				{ ExpTool.FieldType.INT.getValue(),	"CTY_Pop",				"Population" },
				{ ExpTool.FieldType.DBL.getValue(),	"CTY_Area",				"Area Km2" },
				{ ExpTool.FieldType.INT.getValue(),	"CTY_StreetNamesP",		"Street Names" },
				{ ExpTool.FieldType.INT.getValue(),	"CTY_StreetNumbersP",	"Street Numbers" },
				{ ExpTool.FieldType.INT.getValue(),	"CTY_GasStationsP",		"Gas Stations" },
				{ ExpTool.FieldType.INT.getValue(),	"CTY_ParkingLotsP",		"Parking Lots" },
				{ ExpTool.FieldType.INT.getValue(),	"CTY_LandmarksP",		"Places" },
				{ ExpTool.FieldType.INT.getValue(),	"CTY_NodesCheckP",		"Nodes" },
				{ ExpTool.FieldType.INT.getValue(),	"CTY_LockP",			"Lock" },
				{ ExpTool.FieldType.DAT.getValue(),	"CTY_LastUpdated",		"Last Update" },
				{ ExpTool.FieldType.STR.getValue(),	"CTY_LastUpdatedBy",	"Updated by" },
				{ ExpTool.FieldType.STR.getValue(),	"CTY_Notes",			"Notes" }
			};
		
			String Query =
				"SELECT " +
					"GEO_Code, CTY_Name, CTY_Editor, CTY_Lat, CTY_Lng, CTY_Pop, CTY_Area, " +
					"CTY_StreetNamesP, CTY_StreetNumbersP, CTY_GasStationsP, CTY_ParkingLotsP, CTY_LandmarksP, CTY_NodesCheckP, CTY_LockP, " +
					"CTY_Notes, CTY_LastUpdated, CTY_LastUpdatedBy " +
				"FROM " + City.getTblName() + " " +
				"LEFT JOIN AUTH_geo ON GEO_Code = CTY_GeoRef " +
				"WHERE CTY_Editor LIKE '%" + SysTool.getCurrentUser(request) + "%' OR CTY_LastUpdatedBy LIKE '%" + SysTool.getCurrentUser(request) + "%' " +
				"ORDER BY CTY_GeoRef, CTY_Name " +
				"LIMIT " + ExpTool.MAX_XLS_ROWS
			;

			String xlsFile = SysTool.getCurrentUser(request) + "-" + FmtTool.fmtDateTimeFileStyle() + ".xls";
			String xlsFsName = AppCfg.getServerRootPath() + "/manage/exports/" + xlsFile;
			String xlsWebName = AppCfg.getServerHomeUrl() + "/manage/exports/" + xlsFile;

			ExpTool EXP = new ExpTool();

			EXP.XlsExport(DB, FieldList, Query, "CMON Data Export", xlsFsName);

			RedirectTo = "?Action=download&XlsFile=" + URLEncoder.encode(xlsWebName, "UTF-8");

		} else if (Action.equals("download")) {

			////////////////////////////////////////////////////////////////////////////////////////////////////
			//
			// DOWNLOAD
			//

			String XlsFile = EnvTool.getStr(request, "XlsFile", "");
%>
			<div class="DS-card-full" align="center">
				<div class="DS-text-extra-huge DS-text-green DS-text-bold DS-text-italic">XLS file generated successfully</div>
				<a href="<%= XlsFile %>"><img src="../images/256x256/xls.png" title="Download Xls File"></a>
				<div class="DS-text-huge DS-text-green DS-text-italic">Click the icon to download it</div>
			</div>

			<div class="DS-card-foot">
				<%= MdcTool.Button.BackTextIcon("Home", "../manage/") %>
			</div>
<%
		} else
			throw new Exception("Bad Action: '" + Action + "'");

	} catch (Exception e) {

		MSG.setAlertText("Data Export Error", e.toString());
		RedirectTo = "../manage/";
	}
%>
	</div>
	</div>
	</div>

	<jsp:include page="../_common/footer.jsp">
		<jsp:param name="RedirectTo" value="<%= RedirectTo %>" />
	</jsp:include>
<%
	DB.destroy();
%>
</body>
</html>
