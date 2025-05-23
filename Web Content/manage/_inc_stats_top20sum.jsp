<%@ page
	language="java"
	contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="java.sql.*"
	import="java.util.*"
	import="net.danisoft.dslib.*"
	import="net.danisoft.wtlib.auth.*"
	import="net.danisoft.wazetools.*"
	import="net.danisoft.wazetools.cmon.*"
%>
<%!
	/**
	 * Get Regions Data or "ERR: {errorMessage}" on error
	 *
	 * NOTE: Region names must be in ISO 3166-2:IT of GoogleChart fail
	 *       See https://en.wikipedia.org/wiki/ISO_3166-2:IT
	 */
	private static final String getRegionsData() {

		final String TMP_TABLE = "CMON_tmpStats_SUM";

		Database DB = null;
		String regData = "";

		try {

			DB = new Database();
			GeoIso GEO = new GeoIso(DB.getConnection());

			Statement st = DB.getConnection().createStatement();
			Statement stUpd = DB.getConnection().createStatement();
			ResultSet rs = null;

			String RegName;
			double newPercent = 0.0;

			// Create temp table

			st.executeUpdate("DROP TABLE IF EXISTS " + TMP_TABLE);

			st.executeUpdate(
				"CREATE TABLE " + TMP_TABLE + " (" +
					"GeoRef varchar(7) NOT NULL, " +
					"Count decimal(7,2) NOT NULL DEFAULT '0.00', " +
					"StreetNamesP decimal(7,2) DEFAULT NULL, " +
					"StreetNumbersP decimal(7,2) DEFAULT NULL, " +
					"GasStationsP decimal(7,2) DEFAULT NULL, " +
					"ParkingLotsP decimal(7,2) DEFAULT NULL, " +
					"LandmarksP decimal(7,2) DEFAULT NULL, " +
					"NodesCheckP decimal(7,2) DEFAULT NULL, " +
					"LockP decimal(7,2) DEFAULT NULL, " +
					"Percent decimal(7,2) NOT NULL DEFAULT '0.00', " +
					"PRIMARY KEY (GeoRef)" +
				") ENGINE=InnoDB;"
			);

			// Update temp data

			st.executeUpdate(
				"INSERT INTO " + TMP_TABLE + " (" +
					"GeoRef, Count, StreetNamesP, StreetNumbersP, GasStationsP, ParkingLotsP, LandmarksP, NodesCheckP, LockP, Percent" +
				") SELECT " +
					"LEFT(CTY_GeoRef, 7), " +
					"CAST(COUNT(*) AS DECIMAL(7,2)), " +
					"CAST(SUM(CTY_StreetNamesP) AS DECIMAL(7,2)), " +
					"CAST(SUM(CTY_StreetNumbersP) AS DECIMAL(7,2)), " +
					"CAST(SUM(CTY_GasStationsP) AS DECIMAL(7,2)), " +
					"CAST(SUM(CTY_ParkingLotsP) AS DECIMAL(7,2)), " +
					"CAST(SUM(CTY_LandmarksP) AS DECIMAL(7,2)), " +
					"CAST(SUM(CTY_NodesCheckP) AS DECIMAL(7,2)), " +
					"CAST(SUM(CTY_LockP) AS DECIMAL(7,2)), " +
					"CAST(0 AS DECIMAL(7,2)) " +
				"FROM " + City.getTblName() + " " +
					"LEFT JOIN " + GeoIso.getTblName() + " ON CTY_GeoRef = GEO_Code " +
				"GROUP BY LEFT(CTY_GeoRef, 7)"
			);

			st.executeUpdate("UPDATE " + TMP_TABLE + " SET StreetNamesP = StreetNamesP / Count");
			st.executeUpdate("UPDATE " + TMP_TABLE + " SET StreetNumbersP = StreetNumbersP / Count");
			st.executeUpdate("UPDATE " + TMP_TABLE + " SET GasStationsP = GasStationsP / Count");
			st.executeUpdate("UPDATE " + TMP_TABLE + " SET ParkingLotsP = ParkingLotsP / Count");
			st.executeUpdate("UPDATE " + TMP_TABLE + " SET LandmarksP = LandmarksP / Count");
			st.executeUpdate("UPDATE " + TMP_TABLE + " SET NodesCheckP = NodesCheckP / Count");
			st.executeUpdate("UPDATE " + TMP_TABLE + " SET LockP = LockP / Count");

			rs = st.executeQuery("SELECT * FROM " + TMP_TABLE);

			while (rs.next()) {

				RegName = rs.getString("GeoRef");

				newPercent = City.getCompletionPercent(
					rs.getDouble("NodesCheckP"),
					rs.getDouble("StreetNamesP"),
					rs.getDouble("StreetNumbersP"),
					rs.getDouble("GasStationsP"),
					rs.getDouble("ParkingLotsP"),
					rs.getDouble("LandmarksP"),
					rs.getDouble("LockP")
				);

				stUpd.executeUpdate("UPDATE " + TMP_TABLE + " SET Percent = " + newPercent + " WHERE GeoRef = '" + RegName + "'");
			}

			rs.close();

			// Create results array

			rs = st.executeQuery("SELECT * FROM " + TMP_TABLE);

			while (rs.next())
				regData += "[" +
					"\"" + GEO.getDesc(rs.getString("GeoRef")) + "\", " +
					rs.getDouble("Percent") +
				"], ";

			rs.close();

			// Clean

			stUpd.close();

			st.executeUpdate("DROP TABLE IF EXISTS " + TMP_TABLE);
			st.close();

		} catch (Exception e) {
			regData = "ERR: " + e.toString();
		}

		if (DB != null)
			DB.destroy();
		
		return(regData);
	} 
%>
	<div class="DS-text-black DS-back-gray DS-border-dn DS-padding-3px" align="center">Summary</div>
<%
	String RegionsData = getRegionsData();

	if (RegionsData.startsWith("ERR:")) {
%>
		<p class="DS-text-exception"><%= RegionsData %></p>
<%
	} else {
%>
		<div id="DIV_GeoChart" class="DS-padding-lfrg-3px"></div>

		<script>

			function drawRegionsMap() {

				var geoData = google.visualization.arrayToDataTable([
					['Region', 'Percent Complete'],
					<%= RegionsData %>
				]);

				var geochart = new google.visualization.GeoChart(document.getElementById('DIV_GeoChart'));

				var geoOptions = {
					geochartVersion: 11,
					region: 'IT',
					resolution: 'provinces',
					displayMode: 'regions',
					height: 320, keepAspectRatio: true,
					backgroundColor: 'white',
					datalessRegionColor: '#f7f7f7',
					colorAxis: {minValue: <%= CmonColors.STEP_1_5_PERCENT %> },
					colorAxis: {maxValue: <%= CmonColors.STEP_5_5_PERCENT %> },
					colorAxis: {values: [ <%= CmonColors.STEP_1_5_PERCENT %>, <%= CmonColors.STEP_2_5_PERCENT %>, <%= CmonColors.STEP_3_5_PERCENT %>, <%= CmonColors.STEP_4_5_PERCENT %>, <%= CmonColors.STEP_5_5_PERCENT %> ]},
					colorAxis: {colors: ['<%= CmonColors.STEP_1_5_INTERNAL %>', '<%= CmonColors.STEP_2_5_INTERNAL %>', '<%= CmonColors.STEP_3_5_INTERNAL %>', '<%= CmonColors.STEP_4_5_INTERNAL %>', '<%= CmonColors.STEP_5_5_INTERNAL %>' ]}
				};

				geochart.draw(geoData, geoOptions);
			}

			$(document).ready(function() {
				google.charts.load('current', { 'packages': ['geochart'], 'mapsApiKey': '<%= AppCfg.getGMapActvKey() %>'});
				google.charts.setOnLoadCallback(drawRegionsMap);
			});

		</script>
<%		
	}
%>
