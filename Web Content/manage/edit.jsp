<%@ page
	language="java"
	contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="java.sql.*"
	import="net.danisoft.dslib.*"
	import="net.danisoft.wtlib.auth.*"
	import="net.danisoft.wtlib.cmon.*"
	import="net.danisoft.wazetools.*"
	import="net.danisoft.wazetools.cmon.*"
%>
<%!
	private static final String PAGE_Title = AppCfg.getAppName() + " City Editor";
	private static final String PAGE_Keywords = AppCfg.getAppName() + ", Waze, Map, Completion, Monitor, Italy, Italia, City, Editor";
	private static final String PAGE_Description = AppCfg.getAppName() + " interface to edit database data for Countries, Regions, Provinces and Cities in " + AppCfg.getCoveredAreaName();

	// AUTH
	private static final CmonRole taskCanEditCity = CmonRole.EDITOR;
	private static final CmonRole taskCanDragCityPin = CmonRole.CANDRAGPIN;
	private static final CmonRole taskCanEditCityArea = CmonRole.EDITOR;
	private static final CmonRole taskCanEditPopulation = CmonRole.EDITOR;
	private static final CmonRole taskCanAddEditors = CmonRole.ADDEDITOR;

	/**
	 * Check Hierarchy
	 */
	private static boolean checkHierarchy(Connection cn, String UserID, String GeoRef) throws Exception {

		boolean rc = false;

		Statement st = cn.createStatement();
		ResultSet rs = st.executeQuery("SELECT DISTINCT AHI_GeoRef FROM AUTH_hierarchy WHERE AHI_NickName = '" + UserID + "' AND AHI_GeoRef != ''");

		while (rs.next())
			if (GeoRef.equals(rs.getString("AHI_GeoRef")))
				rc = true;

		rs.close();
		st.close();

		return(rc);
	}
	
	/**
	 * Check User Areas
	 */
	private static boolean coordsInUserArea(Connection cn, String UserID, double lat, double lng) throws Exception {

		int intIsIncluded = 0;
		String ShapeText = "";

		Statement st = cn.createStatement();
		ResultSet rs = null;

		// Retrieve User Areas

		rs = st.executeQuery("SELECT CAST(ST_AsText(AUA_Area) AS CHAR) AS ShapeText FROM AUTH_areas WHERE AUA_User = '" + UserID + "'");
		
		while (rs.next())
			ShapeText += (ShapeText.equals("") ? "" : SysTool.getDelimiter()) + rs.getString("ShapeText");

		rs.close();

		if (!ShapeText.equals("")) {

			String Areas[] = ShapeText.split(SysTool.getDelimiter());

			// Check inclusion in at least one area
			
			String POINT = "POINT(" + lng + " " + lat + ")";
			
			for (int i=0; i<Areas.length; i++) {

				rs = st.executeQuery(
					"SELECT MBRContains(" +
						"ST_GeomFromText('" + Areas[i] + "'), " +
						"ST_GeomFromText('" + POINT + "') " +
					") AS Result;"
				);

				if (rs.next())
					if (intIsIncluded == 0)
						intIsIncluded = rs.getInt("Result");

				rs.close();
			}
		}

		st.close();

		return(intIsIncluded > 0);
	}
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
<%
	String RedirectTo = "";

	Database DB = new Database();
	User USR = new User(DB.getConnection());
	City CTY = new City(DB.getConnection());
	LogTool LOG = new LogTool(DB.getConnection());
	MsgTool MSG = new MsgTool(session);
	GeoIso GEO = new GeoIso(DB.getConnection());

	String ComingFrom = EnvTool.getStr(request, "BackUrl", "");

	try {

		User.Data usrData = USR.Read(SysTool.getCurrentUser(request));

		if (!(SysTool.isUserLoggedIn(request)))
			throw new Exception("You don't have enough privileges to access this page");

		boolean UserHasTaskCanEditCity = usrData.getWazerConfig().getCmon().isEnabled(taskCanEditCity);
		boolean UserHasTaskCanEditCityArea = usrData.getWazerConfig().getCmon().isEnabled(taskCanEditCityArea);
		boolean UserHasTaskCanEditPopulation = usrData.getWazerConfig().getCmon().isEnabled(taskCanEditPopulation);
		boolean UserHasTaskCanDragCityPin = usrData.getWazerConfig().getCmon().isEnabled(taskCanDragCityPin);
		boolean UserHasTaskCanAddEditors = usrData.getWazerConfig().getCmon().isEnabled(taskCanAddEditors);

		if (UserHasTaskCanEditCity) {

			String Action = EnvTool.getStr(request, "Action", "");

			int CtyID = EnvTool.getInt(request, "city", 0);
			int ExCty = EnvTool.getInt(request, "excity", 0);
%>
			<div class="<%= MdcTool.Layout.Cell(12, 8, 4) %>">

			<div class="DS-card-body">
				<div class="DS-text-title-shadow"><%= PAGE_Title %></div>
			</div>
<%
			City.Data ctyData = CTY.Read(CtyID);

			if (Action.equals("")) {

				////////////////////////////////////////////////////////////////////////////////////////////////////
				//
				// EDIT
				//

				// Check Permissions

				boolean isHierarchy = checkHierarchy(DB.getConnection(), SysTool.getCurrentUser(request), ctyData.getGeoRef());
				boolean isCoords = coordsInUserArea(DB.getConnection(), SysTool.getCurrentUser(request), ctyData.getLat(), ctyData.getLng());
				boolean isEditor = ctyData.getEditor().contains(SysTool.getCurrentUser(request));

				if (!isHierarchy) {
					if (!isCoords) {
						if (!isEditor) {
							throw new Exception(
								"<b>We are sorry, but " + ctyData.getName() + " is out of your assigned area.</b><br>" +
								"<br>" +
								"You can only edit cities included in your AUTH entitlement, or located in your managed area, or where your nickname appears in the &quot;editors&quot; field.<br>" +
								"Please <a href=\"https://auth.waze.tools/anonymous/hierarchy.jsp\" target=\"_blank\">contact one of the Italian Local Champs</a> and ask him to add your nickname to the editors field."
							);
						}
					}
				}
%>
				<div class="DS-card-body">
					<div class="DS-text-huge">Editing City: <b class="DS-padding-4px DS-back-pastel-green DS-border-full"><%= ctyData.getName() %></b></div>
				</div>

				<form>

				<input type="hidden" name="Action" value="update">
				<input type="hidden" name="city" value="<%= ctyData.getID() %>">
				<input type="hidden" name="excity" value="<%= ExCty %>">

				<div class="DS-card-body">

				<table class="TableSpacing_0px DS-full-width">

				<tr class="DS-border-updn">
					<td class="CellPadding_3px">Area</td>
					<td class="CellPadding_3px">
						<% if (UserHasTaskCanEditCityArea) { %>
							<input class="DS-input-textbox DS-text-right" type="text" name="txtArea" size="8" maxlength="8" value="<%= ctyData.getArea() %>">
						<% } else { %>
							<input type="hidden" name="txtArea" value="<%= ctyData.getArea() %>">
							<span class="DS-input-textbox"><%= ctyData.getArea() %></span>
						<% } %>
						Km&sup2;
					</td>
					<td class="CellPadding_0px" RowSpan="13" align="center">
						<div class="<%= MdcTool.Elevation.Normal() %>" id="<%= AppCfg.getMapContainerId() %>" style="position:relative; width:600px; height:400px;"></div>
					</td>
				</tr>

				<tr class="DS-border-dn">
					<td class="CellPadding_3px">Coords</td>
					<td class="CellPadding_3px">
						<% if (UserHasTaskCanDragCityPin) { %>
							<input class="DS-input-textbox DS-text-right" type="text" readonly id="txtLat" name="txtLat" size="8" maxlength="8" value="<%= ctyData.getLat() %>">
							<input class="DS-input-textbox DS-text-right" type="text" readonly id="txtLng" name="txtLng" size="8" maxlength="8" value="<%= ctyData.getLng() %>">
						<% } else { %>
							<input type="hidden" name="txtLat" value="<%= ctyData.getLat() %>">
							<input type="hidden" name="txtLng" value="<%= ctyData.getLng() %>">
							<div class="DS-input-textbox"><%= ctyData.getLat() %>, <%= ctyData.getLng() %></div>
						<% } %>
					</td>
				</tr>

				<tr class="DS-border-dn">
					<td class="CellPadding_3px">GEO Location</td>
					<td class="CellPadding_3px">
						<% if (usrData.getWazerConfig().getCmon().isEnabled(CmonRole.EDITGEOREF)	/* isRoleEnabled(usrConfig, CmonRole.EDITGEOREF) */		) { %>
							<select name="cmbGeoRef" class="DS-input-textbox">
								<%= GEO.getStateDistrictCombo("ITA", ctyData.getGeoRef()) %>
							</select>
						<% } else { %>
							<input type="hidden" name="cmbGeoRef" value="<%= ctyData.getGeoRef() %>">
							<div class="DS-input-textbox"><%= GEO.getFullDesc(ctyData.getGeoRef()) %></div>
						<% } %>
					</td>
				</tr>

				<tr class="DS-border-dn">
					<td class="CellPadding_3px">Population</td>
					<td class="CellPadding_3px">
						<% if (UserHasTaskCanEditPopulation) { %>
							<input type="text" class="DS-input-textbox DS-text-right" name="txtPop" size="8" maxlength="8" value="<%= ctyData.getPop() %>">
						<% } else { %>
							<input type="hidden" name="txtPop" value="<%= ctyData.getPop() %>">
							<div class="DS-input-textbox"><%= ctyData.getPop() %></div>
						<% } %>
					</td>
				</tr>

				<tr class="DS-border-dn">
					<td class="CellPadding_3px">Active Editors</td>
					<td class="CellPadding_3px">
						<% if (UserHasTaskCanAddEditors) { %>
							<input class="DS-input-textbox DS-full-width" type="text" name="txtEditor" size="50" value="<%= ctyData.getEditor() %>" title="Enter UserIDs in comma separated style">
						<% } else { %>
							<input type="hidden" name="txtEditor" value="<%= ctyData.getEditor() %>">
							<div class="DS-input-textbox"><%= ctyData.getEditor().trim().equals("") ? "<span class=\"Disabled\">[nobody]</span>" : ctyData.getEditor() %></div>
						<% } %>
					</td>
				</tr>

				<tr class="DS-border-dn"><td class="CellPadding_3px">Street Names</td>			<td class="CellPadding_3px"><input type="text" class="DS-input-textbox DS-text-right" name="txtStreetNamesP" size="3" maxlength="3" value="<%= ctyData.getStreetNamesP() %>"> % completed</td></tr>
				<tr class="DS-border-dn"><td class="CellPadding_3px">Street Numbers</td>		<td class="CellPadding_3px"><input type="text" class="DS-input-textbox DS-text-right" name="txtStreetNumbersP" size="3" maxlength="3" value="<%= ctyData.getStreetNumbersP() %>"> % completed</td></tr>
				<tr class="DS-border-dn"><td class="CellPadding_3px">Gas Stations</td>			<td class="CellPadding_3px"><input type="text" class="DS-input-textbox DS-text-right" name="txtGasStationsP" size="3" maxlength="3" value="<%= ctyData.getGasStationsP() %>"> % completed</td></tr>
				<tr class="DS-border-dn"><td class="CellPadding_3px">Parking Lots</td>			<td class="CellPadding_3px"><input type="text" class="DS-input-textbox DS-text-right" name="txtParkingLotsP" size="3" maxlength="3" value="<%= ctyData.getParkingLotsP() %>"> % completed</td></tr>
				<tr class="DS-border-dn"><td class="CellPadding_3px">Landmarks</td>				<td class="CellPadding_3px"><input type="text" class="DS-input-textbox DS-text-right" name="txtLandmarksP" size="3" maxlength="3" value="<%= ctyData.getLandmarksP() %>"> % completed</td></tr>
				<tr class="DS-border-dn"><td class="CellPadding_3px">Nodes Check</td>			<td class="CellPadding_3px"><input type="text" class="DS-input-textbox DS-text-right" name="txtNodesCheckP" size="3" maxlength="3" value="<%= ctyData.getNodesCheckP() %>"> % completed</td></tr>
				<tr class="DS-border-dn"><td class="CellPadding_3px">Objects Lock</td>			<td class="CellPadding_3px"><input type="text" class="DS-input-textbox DS-text-right" name="txtLockP" size="3" maxlength="3" value="<%= ctyData.getLockP() %>"> % completed</td></tr>
				<tr class="DS-border-dn"><td class="CellPadding_3px" valign="top">Notes</td>	<td class="CellPadding_3px" valign="top"><textarea class="DS-input-textbox" name="txtNotes" style="height: 100%; width: 100%" rows="3"><%= ctyData.getNotes() %></textarea></td></tr>

				</table>
				</div>

				<div class="DS-card-foot">
					<table class="TableSpacing_0px DS-full-width">
						<tr>
							<td class="CellPadding_0px" width="25%" align="left">
								<%= MdcTool.Button.BackTextIcon("Cancel", (ExCty == 0 ? "../manage/" : "details.jsp?excity=" + ExCty)) %>
							</td>
							<td class="CellPadding_0px" width="50%" align="center">
								<div class="DS-text-compact DS-text-italic DS-text-gray">Last Modified: <%= FmtTool.fmtDateTime(ctyData.getLastUpdated()) %> by <%= ctyData.getLastUpdatedBy().trim().equals("") ? "[unknown]" : ctyData.getLastUpdatedBy() %></div>
							</td>
							<td class="CellPadding_0px" width="25%" align="right">
								<%= MdcTool.Button.SubmitTextIconClass("save", "&nbsp;Save", null, "DS-text-lime", null, "Save Data") %>
							</td>
						</tr>
					</table>
				</div>
				
				</form>
<%
			} else if (Action.equals("update")) {
		
				////////////////////////////////////////////////////////////////////////////////////////////////////
				//
				// UPDATE
				//

				// Mail MAIL = new Mail();

				String UpdStuff = "";

				// Log important changes

				if (ctyData.getArea() != EnvTool.getDbl(request, "txtArea", 0.0))					UpdStuff += " - Area " + ctyData.getArea() + " -> " + EnvTool.getDbl(request, "txtArea", 0.0);
				if (ctyData.getLat() != EnvTool.getDbl(request, "txtLat", 0.0))						UpdStuff += " - Lat " + ctyData.getLat() + " -> " + EnvTool.getDbl(request, "txtLat", 0.0);
				if (ctyData.getLng() != EnvTool.getDbl(request, "txtLng", 0.0))						UpdStuff += " - Lng " + ctyData.getLng() + " -> " + EnvTool.getDbl(request, "txtLng", 0.0);
				if (ctyData.getPop() != EnvTool.getInt(request, "txtPop", 0))						UpdStuff += " - Population " + ctyData.getPop() + " -> " + EnvTool.getInt(request, "txtPop", 0);
				if (!ctyData.getGeoRef().equals(EnvTool.getStr(request, "cmbGeoRef", "")))			UpdStuff += " - GeoRef '" + ctyData.getGeoRef() + "' -> '" + EnvTool.getStr(request, "cmbGeoRef", "") + "'";
				if (!ctyData.getEditor().equals(EnvTool.getStr(request, "txtEditor", "")))			UpdStuff += " - Editor(s) '" + ctyData.getEditor() + "' -> '" + EnvTool.getStr(request, "txtEditor", "") + "'";
				if (!ctyData.getNotes().equals(EnvTool.getStr(request, "txtNotes", "")))			UpdStuff += " - Notes '" + ctyData.getNotes() + "' -> '" + EnvTool.getStr(request, "txtNotes", "") + "'";

				if (ctyData.getStreetNamesP() != EnvTool.getInt(request, "txtStreetNamesP", 0))		UpdStuff += " - Street Names '" + ctyData.getStreetNamesP() + "' -> '" + EnvTool.getInt(request, "txtStreetNamesP", 0) + "'";
				if (ctyData.getStreetNumbersP() != EnvTool.getInt(request, "txtStreetNumbersP", 0))	UpdStuff += " - Street Numbers '" + ctyData.getStreetNumbersP() + "' -> '" + EnvTool.getInt(request, "txtStreetNumbersP", 0) + "'";
				if (ctyData.getGasStationsP() != EnvTool.getInt(request, "txtGasStationsP", 0))		UpdStuff += " - Gas Stations '" + ctyData.getGasStationsP() + "' -> '" + EnvTool.getInt(request, "txtGasStationsP", 0) + "'";
				if (ctyData.getParkingLotsP() != EnvTool.getInt(request, "txtParkingLotsP", 0))		UpdStuff += " - Parking Lots '" + ctyData.getParkingLotsP() + "' -> '" + EnvTool.getInt(request, "txtParkingLotsP", 0) + "'";
				if (ctyData.getLandmarksP() != EnvTool.getInt(request, "txtLandmarksP", 0))			UpdStuff += " - Landmarks '" + ctyData.getLandmarksP() + "' -> '" + EnvTool.getInt(request, "txtLandmarksP", 0) + "'";
				if (ctyData.getNodesCheckP() != EnvTool.getInt(request, "txtNodesCheckP", 0))		UpdStuff += " - Nodes Check '" + ctyData.getNodesCheckP() + "' -> '" + EnvTool.getInt(request, "txtNodesCheckP", 0) + "'";
				if (ctyData.getLockP() != EnvTool.getInt(request, "txtLockP", 0))					UpdStuff += " - Objects Lock '" + ctyData.getLockP() + "' -> '" + EnvTool.getInt(request, "txtLockP", 0) + "'";

				// Update data

				ctyData.setGeoRef(EnvTool.getStr(request, "cmbGeoRef", ""));
				ctyData.setProvince(EnvTool.getInt(request, "cmbProvince", 0));
				ctyData.setLat(EnvTool.getDbl(request, "txtLat", 0.0));
				ctyData.setLng(EnvTool.getDbl(request, "txtLng", 0.0));
				ctyData.setPop(EnvTool.getInt(request, "txtPop", 0));
				ctyData.setEditor(EnvTool.getStr(request, "txtEditor", ""));
				ctyData.setArea(EnvTool.getDbl(request, "txtArea", 0.0));
				ctyData.setStreetNamesP(EnvTool.getInt(request, "txtStreetNamesP", 0));
				ctyData.setStreetNumbersP(EnvTool.getInt(request, "txtStreetNumbersP", 0));
				ctyData.setGasStationsP(EnvTool.getInt(request, "txtGasStationsP", 0));
				ctyData.setParkingLotsP(EnvTool.getInt(request, "txtParkingLotsP", 0));
				ctyData.setLandmarksP(EnvTool.getInt(request, "txtLandmarksP", 0));
				ctyData.setNodesCheckP(EnvTool.getInt(request, "txtNodesCheckP", 0));
				ctyData.setLockP(EnvTool.getInt(request, "txtLockP", 0));
				ctyData.setNotes(EnvTool.getStr(request, "txtNotes", ""));
				ctyData.setLastUpdated(FmtTool.getCurrentTimestamp());
				ctyData.setLastUpdatedBy(SysTool.getCurrentUser(request));

				// Check Percent Values

				if (ctyData.getStreetNamesP() < 0	|| ctyData.getStreetNamesP() > 100		||
					ctyData.getStreetNumbersP() < 0	|| ctyData.getStreetNumbersP() > 100	||
					ctyData.getGasStationsP() < 0	|| ctyData.getGasStationsP() > 100		||
					ctyData.getParkingLotsP() < 0	|| ctyData.getParkingLotsP() > 100		||
					ctyData.getLandmarksP() < 0		|| ctyData.getLandmarksP() > 100		||
					ctyData.getNodesCheckP() < 0	|| ctyData.getNodesCheckP() > 100		||
					ctyData.getLockP() < 0			|| ctyData.getLockP() > 100) {

					MSG.setAlertText("Error updating City Data", "Completion percent values must be between 0 and 100");

				} else {

					// Add logged in user if not present and there are no other editors

					if (ctyData.getEditor().trim().equals("")) {
						ctyData.setEditor(SysTool.getCurrentUser(request));
						UpdStuff += " - Editor(s) '' -> '" + ctyData.getEditor() + "' (automagically inserted)";
					}

					// Update

					CTY.Update(CtyID, ctyData);

					if (!UpdStuff.equals(""))
						LOG.Info(request, LogTool.Category.CMON, "City Edit (ID:" + ctyData.getID() + ") [" + ctyData.getName() + "] - Updated fields:" + UpdStuff);

					MSG.setSnackText("City Data Updated");

				}

				RedirectTo = (ExCty == 0 ? "../manage/" : "details.jsp?excity=" + ExCty);

			} else {

				////////////////////////////////////////////////////////////////////////////////////////////////////
				//
				// UNKNOWN ACTION
				//
			
				throw new Exception("BAD ACTION CODE: '" + Action + "'");
			}

%>
		</div>

		<!--
			MAP LOAD
		-->

		<script>

			var map;

			function loadCityMap() {

				var MapObj = new Microsoft.Maps.Map(document.getElementById('<%= AppCfg.getMapContainerId() %>'), {
					credentials: '<%= AppCfg.getMapActivationKey() %>',
					disableBirdseye: true,
					enableClickableLogo: false,
					enableSearchLogo: false,
					showDashboard: true,
					zoom: 12,
					center: new Microsoft.Maps.Location(<%= ctyData.getLat() %>, <%= ctyData.getLng() %>),
					mapTypeId: Microsoft.Maps.MapTypeId.auto
				});

				// Create Pushpin

				var PushPin = new Microsoft.Maps.Pushpin(
					new Microsoft.Maps.Location(<%= ctyData.getLat() %>, <%= ctyData.getLng() %>), {
						draggable: <%= UserHasTaskCanDragCityPin ? "true" : "false" %>
					}
				);

				// Change LAT/LNG on Pushpin Drag

				Microsoft.Maps.Events.addHandler(PushPin, 'drag', function(e) {
					$('#txtLat').val(e.location.latitude.toFixed(7));
					$('#txtLng').val(e.location.longitude.toFixed(7));
				});

				// Add PushPin to the map

				MapObj.entities.push(PushPin);
			}

		</script>

		<script src='https://www.bing.com/api/maps/mapcontrol?callback=loadCityMap' defer></script>
<%
		} else {

			MSG.setAlertText("Insufficient Authorization", "Sorry, a permission of type '" + taskCanEditCity.getDescr() + "' <b>is required</b> to edit DB data");
			LOG.Error(request, LogTool.Category.USER, "City Edit - Insufficient Authorization");

			RedirectTo = "../manage/";
		}

	} catch (Exception e) {

		MSG.setAlertText("Exception", e.toString());
		LOG.Error(request, LogTool.Category.CMON, "City Edit - Exception: " + e.toString());

		RedirectTo = ComingFrom.equals("") ? "../manage/" : ComingFrom;
	}

	DB.destroy();
%>
	</div>
	</div>

	<jsp:include page="../_common/footer.jsp">
		<jsp:param name="RedirectTo" value="<%= RedirectTo %>" />
	</jsp:include>

</body>
</html>
