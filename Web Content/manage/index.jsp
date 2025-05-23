<%@ page
	language="java"
	contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="net.danisoft.dslib.*"
	import="net.danisoft.wazetools.*"
	import="net.danisoft.wazetools.cmon.*"
%>
<%!
	private static final String PAGE_Title = AppCfg.getAppName();
	private static final String PAGE_Keywords = AppCfg.getAppName() + ", Waze, Map, Completion, Monitor, Italy, Italia";
	private static final String PAGE_Description = AppCfg.getAppName() + " is a graphic interface to monitor the completion status of the Waze Map in " + AppCfg.getCoveredAreaName();

	private static final int	DEFAULT_ZOOM		= 12;
	private static final double	DEFAULT_CENTER_LAT	= 45.537287;
	private static final double	DEFAULT_CENTER_LNG	= 9.928637;

	private static final double	POLY_STROKE_WEIGHT				= 1.00D;
	private static final double	POLY_EXTERNAL_OPACITY			= 0.40D;
	private static final double	POLY_INTERNAL_OPACITY			= 0.15D;
	private static final double	POLY_INTERNAL_OPACITY_MOUSEOVER	= 0.55D;
%>
<!DOCTYPE html>
<html>
<head>

	<jsp:include page="../_common/head.jsp">
		<jsp:param name="PAGE_Title" value="<%= PAGE_Title %>"/>
		<jsp:param name="PAGE_Keywords" value="<%= PAGE_Keywords %>"/>
		<jsp:param name="PAGE_Description" value="<%= PAGE_Description %>"/>
	</jsp:include>

	<script>

	var MapObj = null;
	var tmpInfoBox = null;

	const DLG_MODAL		= true;	const DLG_MODELESS		= false;
	const DLG_DRAGGABLE	= true;	const DLG_NOT_DRAGGABLE	= false;
	const DLG_RESIZABLE	= true;	const DLG_NOT_RESIZABLE	= false;

	/**
	 * Get Map Objects Fill Colors
	 *
	 * ##########################################################
	 * ##                                                      ##
	 * ##  Please modify color values in CmonColors.java only  ##
	 * ##                                                      ##
	 * ##########################################################
	 */
	function getMapObjFillColor(value) {

		return(
			value == <%= CmonColors.STEP_5_5_PERCENT %> ? '<%= CmonColors.STEP_5_5_INTERNAL %>' : (
				value >= <%= CmonColors.STEP_4_5_PERCENT %> ? '<%= CmonColors.STEP_4_5_INTERNAL %>' : (
					value >= <%= CmonColors.STEP_3_5_PERCENT %> ? '<%= CmonColors.STEP_3_5_INTERNAL %>' : (
						value >= <%= CmonColors.STEP_2_5_PERCENT %> ? '<%= CmonColors.STEP_2_5_INTERNAL %>' : (
							'<%= CmonColors.STEP_1_5_INTERNAL %>'
						)
					)
				)
			)
		);
	}

	/**
	 * Get Map Objects Stroke Colors
	 */
	function getMapObjStrokeColor(value) {

		return(
			value == <%= CmonColors.STEP_5_5_PERCENT %> ? '<%= CmonColors.STEP_5_5_EXTERNAL %>' : (
				value >= <%= CmonColors.STEP_4_5_PERCENT %> ? '<%= CmonColors.STEP_4_5_EXTERNAL %>' : (
					value >= <%= CmonColors.STEP_3_5_PERCENT %> ? '<%= CmonColors.STEP_3_5_EXTERNAL %>' : (
						value >= <%= CmonColors.STEP_2_5_PERCENT %> ? '<%= CmonColors.STEP_2_5_EXTERNAL %>' : (
							'<%= CmonColors.STEP_1_5_EXTERNAL %>'
						)
					)
				)
			)
		);
	}

	/**
	 * Show a progress dialog
	 */
	function ShowProgress(title, height, width, modal, draggable, resizable, content) {

		var newDiv = document.createElement('div');

		newDiv.innerHTML = content;

		return(
			$(newDiv).dialog({
				title: title,
				modal: modal,
				draggable: draggable,
				resizable: resizable,
				height: height,
				width: width
			})
		);
	}

	/**
	 * Create Polygons Data from DB via AJAX
	 */
	function getPolygonsData(objMap, ViewStyle) {

		var progressDialog = null;

		$.ajax({

			method: "POST",
			cache: true,
			timeout: 5000,
			url: '../servlet/GetCitiesPolygons',

			data: {
				latMin: objMap.getBounds().getSouth(),
				latMax: objMap.getBounds().getNorth(),
				lngMin: objMap.getBounds().getWest(),
				lngMax: objMap.getBounds().getEast(),
				zoomLevel: objMap.getZoom()
			},

			beforeSend: function (xhr) {
				$('#AjaxLoaderDIV').show();
			},

			error: function(jqXHR, textStatus, errorThrown) {
				console.error('getPolygonsData() ERROR: %o', jqXHR);
				ShowProgress(
					'getPolygonsData() ERROR', 300, 700, DLG_MODAL, DLG_DRAGGABLE, DLG_RESIZABLE,
					'<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">' +
						'<tr>' +
							'<td align="center" class="DS-text-exception">' +
							'Error ' + jqXHR.status + ' in AJAX call: ' + jqXHR.statusText +
							'</td>' +
						'</tr>' +
					'</table>'
				);
			},

			success: function(data, textStatus, jqXHR ) {

				var CityPolygonsScript = document.createElement("script");
				CityPolygonsScript.innerHTML = data;
				document.head.appendChild(CityPolygonsScript);

				getCityPolygons();

				MapObj.entities.clear();

				// Construct the polygon for each value in citypolygons

				var poly = null;
				var newObject = null;

				for (poly in citypolygons) {

					if (ViewStyle == 'L')
						citypolygons[poly].poly = ''; // Force labels only

					if (citypolygons[poly].poly != '') {

						// Set Polygon Colors

						var polygonFillColor = new Microsoft.Maps.Color.fromHex(getMapObjFillColor(citypolygons[poly].percent));
						var polygonStrokeColor = new Microsoft.Maps.Color.fromHex(getMapObjStrokeColor(citypolygons[poly].percent));

						polygonFillColor.a = <%= POLY_INTERNAL_OPACITY %>;
						polygonStrokeColor.a = <%= POLY_EXTERNAL_OPACITY %>;
						
						if (ViewStyle == 'B')
							polygonFillColor.a = 0; // Force borders only

						// Create Polygon

						newObject = Microsoft.Maps.WellKnownText.read(citypolygons[poly].poly, {
							polylineOptions: {
								strokeColor: polygonStrokeColor,
								strokeThickness: ViewStyle == 'B' ? 3 : <%= POLY_STROKE_WEIGHT %>
							},
							polygonOptions: {
								fillColor: polygonFillColor,
								strokeColor: polygonStrokeColor,
								strokeThickness: ViewStyle == 'B' ? 3 : <%= POLY_STROKE_WEIGHT %>
							}
						});

						MapObj.entities.push(newObject);

						// Wire events for polygon color change

						Microsoft.Maps.Events.addHandler(newObject, 'mouseover', function(e) {

							var polygonFillColor = e.target.getFillColor();
							polygonFillColor.a = <%= POLY_INTERNAL_OPACITY_MOUSEOVER %>;
							e.target.setOptions( { fillColor: polygonFillColor } );
						});

						Microsoft.Maps.Events.addHandler(newObject, 'mouseout', function(e) {

							var polygonFillColor = e.target.getFillColor();
							polygonFillColor.a = <%= POLY_INTERNAL_OPACITY %>;

							if (ViewStyle == 'B')
								polygonFillColor.a = 0; // Force borders only

							e.target.setOptions( { fillColor: polygonFillColor } );
						});

					} else {

						// No POLY data found, create a simple pushpin

						newObject = new Microsoft.Maps.Pushpin(
							citypolygons[poly].center, {
								draggable: false,
								enableHoverStyle: true,
								title: citypolygons[poly].name,
								color: getMapObjFillColor(citypolygons[poly].percent)
							}
						);

						MapObj.entities.push(newObject);
					}

					// Add metadata to the newly created object

					newObject.metadata = {
						center: citypolygons[poly].center,
						id: citypolygons[poly].id,
						lat: citypolygons[poly].center.latitude,
						lon: citypolygons[poly].center.longitude,
						title: citypolygons[poly].name,
						description:
							'<table class="TableSpacing_0px DS-text-force-cond DS-full-width">' +
								'<tr class="DS-text-large">' +
									'<td class="CellPadding_3px" align="right" valign="top" nowrap>' +
										'Editors:' +
									'</td>' +
									'<td class="CellPadding_3px" align="left" valign="top" nowrap>' +
										'<b>' + citypolygons[poly].editor + '</b>' +
									'</td>' +
								'</tr>' +
								'<tr class="DS-text-large">' +
									'<td class="CellPadding_3px" align="right" valign="top" nowrap>' +
										'Updated By:' +
									'</td>' +
									'<td class="CellPadding_3px" align="left" valign="top" nowrap>' +
										'<b>' + citypolygons[poly].lastupdby + '</b>' +
									'</td>' +
								'</tr>' +
								'<tr class="DS-text-large">' +
									'<td class="CellPadding_3px" align="right" valign="top" nowrap>' +
										'Last Update:' +
									'</td>' +
									'<td class="CellPadding_3px" align="left" valign="top" nowrap>' +
										'<b>' + citypolygons[poly].lastupd + '</b>' +
									'</td>' +
								'</tr>' +
							'</table>'
					};

					// Wire events for click (all objects) - e.target contains the [Polygon] object

					Microsoft.Maps.Events.addHandler(newObject, 'click', function(e) {

						try {
							tmpInfoBox.setMap(null);
						} catch (err) { }

						tmpInfoBox = new Microsoft.Maps.Infobox(e.target.metadata.center, {
							visible: true,
							maxWidth: 500,
							maxHeight: 300,
							title: e.target.metadata.title,
							description: e.target.metadata.description,
							showPointer: true,
							actions: [{
								label: 'Edit CMON Data', eventHandler: function () {
									window.location.href='edit.jsp?city=' + e.target.metadata.id;
								}
							}, {
								label: 'Edit in WME', eventHandler: function () {
									window.open('https://www.waze.com/editor/?env=row&zoom=4&lat=' + e.target.metadata.lat + '&lon=' + e.target.metadata.lon, '_blank');
								}
							}]
						});

						tmpInfoBox.setMap(MapObj);
					});

				}
			},

			complete: function(jqXHR, textStatus) {
				$('#AjaxLoaderDIV').hide();
			}
		});

	}

	/**
	 * Create User's Areas overlay
	 */
	function getUserOverlay() {

		$.ajax({

			type: "GET",
			cache: false,
			dataType: 'json',
			contentType: 'application/json',
			url: '../servlet/GetEditorArea',
			data: { UserID: '<%= SysTool.getCurrentUser(request) %>' },

			beforeSend: function (xhr) {
				$('#AjaxLoaderDIV').show();
			},
			
			success: function (data, textStatus, jqXHR) {

				if (data['rc'] == <%= HttpServletResponse.SC_OK %>) {

					// Set Polygon Options

					var polygonFillColor = new Microsoft.Maps.Color.fromHex('#FFFFFF');
					var polygonStrokeColor = new Microsoft.Maps.Color.fromHex('#000077');

					polygonFillColor.a = 0;
					polygonStrokeColor.a = .5;
					
					var UserOverlayOptions = {
						pushpinOptions: {
							color: 'pink'
						},
						polylineOptions: {
							strokeColor: polygonStrokeColor,
							strokeDashArray: '5 3 1 3',
							strokeThickness: 3
						},
						polygonOptions: {
							fillColor: polygonFillColor,
							strokeColor: polygonStrokeColor,
							strokeDashArray: '5 3 1 3',
							strokeThickness: 3
						}
					};

					// Retrieve script & run

					var UserAreasScript = document.createElement("script");
					UserAreasScript.innerHTML = data['script'];
					document.head.appendChild(UserAreasScript);

					DrawEditorAreas(MapObj, UserOverlayOptions);

				} else {

					var currUser = '<%= SysTool.getCurrentUser(request) %>';

					console.group('%cGetEditorArea() ERROR', 'font-weight: bold; color: red');
					console.error('currUser: %o', currUser);
					console.error('data["rc"]: %o', data['rc']);
					console.error('data["script"]: %o', data['script']);
					console.groupEnd('GetEditorArea() ERROR');
				}
			},

			complete: function (jqXHR, textStatus) {
				$('#AjaxLoaderDIV').hide();
			}

		});
	}

	/**
	 * Store view options
	 */
	function ViewOptChanged(obj) {

		if (obj.name == 'optCityView')
			setCookie('wme-cm-view', obj.value);

		DrawMap();
	}

	/**
	 * Draw Map CallBack
	 */
	function DrawMap() {

		var mapDefaultZoom = parseInt('0' + getCookie('wme-cm-zoom'));
		var mapDefaultCLat = parseFloat('0' + getCookie('wme-cm-clat'));
		var mapDefaultCLng = parseFloat('0' + getCookie('wme-cm-clng'));
	
		mapDefaultZoom = (mapDefaultZoom == 0 ? <%= DEFAULT_ZOOM %> : mapDefaultZoom);
		mapDefaultCLat = (mapDefaultCLat == 0 ? <%= DEFAULT_CENTER_LAT %> : mapDefaultCLat);
		mapDefaultCLng = (mapDefaultCLng == 0 ? <%= DEFAULT_CENTER_LNG %> : mapDefaultCLng);

		// Retrieve and set Default View

		var mapDefaultView = getCookie('wme-cm-view');

		if (mapDefaultView == 'B') $('#optCityViewB').attr('checked', true); else
		if (mapDefaultView == 'L') $('#optCityViewL').attr('checked', true); else
			$('#optCityViewF').attr('checked', true);

		// Set MAP options

		const mapOptions = {
			credentials: '<%= AppCfg.getMapActivationKey() %>',
			disableBirdseye: true,
			enableClickableLogo: false,
			enableSearchLogo: false,
			showDashboard: false,
			zoom: mapDefaultZoom,
			center: new Microsoft.Maps.Location(mapDefaultCLat, mapDefaultCLng),
			mapTypeId: Microsoft.Maps.MapTypeId.auto
		};

		// MAP Creation

		MapObj = new Microsoft.Maps.Map(document.getElementById('<%= AppCfg.getMapContainerId() %>'), mapOptions);

		// Load the Well Known Text module.

		Microsoft.Maps.loadModule('Microsoft.Maps.WellKnownText', function () {

			const EVT_THROTTLE_MSEC = 250;

			getPolygonsData(MapObj, mapDefaultView);
			getUserOverlay(MapObj, mapOptions);

			// Refresh data from DB on 'viewchangeend' event with 'EVT_THROTTLE_MSEC' msecs of delay

			Microsoft.Maps.Events.addThrottledHandler(MapObj, 'viewchangeend', function() {

				getPolygonsData(MapObj, mapDefaultView);
				getUserOverlay(MapObj, mapOptions);

				// Store Zoom & Center in cookies

				setCookie('wme-cm-zoom', MapObj.getZoom());
				setCookie('wme-cm-clat', MapObj.getCenter().latitude);
				setCookie('wme-cm-clng', MapObj.getCenter().longitude);

			}
			, EVT_THROTTLE_MSEC);
		});

	}

	</script>

	<script defer src="https://www.bing.com/api/maps/mapcontrol?callback=DrawMap"></script>

</head>

<body>

	<jsp:include page="../_common/header.jsp">
		<jsp:param name="Force-Hide" value="Y"/>
	</jsp:include>

	<div id="<%= AppCfg.getMapContainerId() %>" style="position: absolute; top: 0px; left: 0px; width: 100%; height: 100%; z-index: -1;"></div>

	<div class="DS-menubtn-div" style="left: 0px; top: 48px;">
		<table class="TableSpacing_0px DS-text-compact">
			<tr>
				<td class="CellPadding_3px">
					<%= MdcTool.Button.Icon("summarize", "onClick=\"window.location.href='../manage/details.jsp'\"", "Details View") %>
					<%= MdcTool.Button.Icon("trending_up", "onClick=\"window.location.href='../manage/stats.jsp'\"", "Statistics View") %>
					<%= MdcTool.Button.Icon("file_download", "onClick=\"window.location.href='../manage/export.jsp'\"", "Export your data") %>
				</td>
			</tr>
		</table>
	</div>

	<div class="DS-options-div DS-text-compact" style="right: 10px; top: 55px;">
		<table class="TableSpacing_0px">
			<tr>
				<td class="CellPadding_3px DS-back-gray DS-text-bold" align="center">City View Options</td>
			</tr>
			<tr>
				<td class="CellPadding_3px">
					<input type="radio" id="optCityViewF" name="optCityView" value="F" onClick="ViewOptChanged(this);"><label for="optCityViewF">Full colors</label><br>
					<input type="radio" id="optCityViewB" name="optCityView" value="B" onClick="ViewOptChanged(this);"><label for="optCityViewB">Borders only</label><br>
					<input type="radio" id="optCityViewL" name="optCityView" value="L" onClick="ViewOptChanged(this);"><label for="optCityViewL">Pushpins only</label>
				</td>
			</tr>
		</table>
	</div>

	<div id="AjaxLoaderDIV" class="DS-ajax-loader-div" style="display: none">
		<div align="center"><img src="../images/ajax-loader.gif"></div>
		<div align="center">Loading...</div>
	</div>

	<jsp:include page="../_common/footer.jsp">
		<jsp:param name="Force-Hide" value="Y"/>
	</jsp:include>

</body>
</html>
