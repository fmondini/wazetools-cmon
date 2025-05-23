<%@ page
	language="java"
	contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="java.sql.*"
	import="java.util.*"
	import="net.danisoft.dslib.*"
	import="net.danisoft.wtlib.auth.*"
	import="net.danisoft.wazetools.cmon.*"
%>
<%!
	final String TMP_TABLE = "CMON_tmpStats_PRV";
%>
	<div class="DS-text-black DS-back-gray DS-border-dn DS-padding-3px" align="center">TOP 20 Provinces</div>

	<table class="TableSpacing_0px DS-full-width DS-text-compact">
<%
	Database DB = new Database();
	GeoIso GEO = new GeoIso(DB.getConnection());

	String PrvName;
	double newPercent;

	try {

		Statement st = DB.getConnection().createStatement();
		Statement stUpd = DB.getConnection().createStatement();
		ResultSet rs = null;

		st.executeUpdate("DROP TABLE IF EXISTS " + this.TMP_TABLE);

		st.executeUpdate(
			"CREATE TABLE " + this.TMP_TABLE + " (" +
				"GeoRef varchar(10) NOT NULL, " +
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

		st.executeUpdate(
			"INSERT INTO " + this.TMP_TABLE + " (" +
				"GeoRef, Count, StreetNamesP, StreetNumbersP, GasStationsP, ParkingLotsP, LandmarksP, NodesCheckP, LockP, Percent" +
			") SELECT " +
				"CTY_GeoRef AS GeoRef, " +
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
			"GROUP BY CTY_GeoRef"
		);

		st.executeUpdate("UPDATE " + this.TMP_TABLE + " SET StreetNamesP = StreetNamesP / Count");
		st.executeUpdate("UPDATE " + this.TMP_TABLE + " SET StreetNumbersP = StreetNumbersP / Count");
		st.executeUpdate("UPDATE " + this.TMP_TABLE + " SET GasStationsP = GasStationsP / Count");
		st.executeUpdate("UPDATE " + this.TMP_TABLE + " SET ParkingLotsP = ParkingLotsP / Count");
		st.executeUpdate("UPDATE " + this.TMP_TABLE + " SET LandmarksP = LandmarksP / Count");
		st.executeUpdate("UPDATE " + this.TMP_TABLE + " SET NodesCheckP = NodesCheckP / Count");
		st.executeUpdate("UPDATE " + this.TMP_TABLE + " SET LockP = LockP / Count");

		rs = st.executeQuery("SELECT * FROM " + this.TMP_TABLE);

		while (rs.next()) {

			PrvName = rs.getString("GeoRef");

			newPercent = City.getCompletionPercent(
				rs.getDouble("NodesCheckP"),
				rs.getDouble("StreetNamesP"),
				rs.getDouble("StreetNumbersP"),
				rs.getDouble("GasStationsP"),
				rs.getDouble("ParkingLotsP"),
				rs.getDouble("LandmarksP"),
				rs.getDouble("LockP")
			);

			stUpd.executeUpdate("UPDATE " + this.TMP_TABLE + " SET Percent = " + newPercent + " WHERE GeoRef = '" + PrvName + "'");
		}

		rs.close();

		// Read

		rs = st.executeQuery("SELECT * FROM " + this.TMP_TABLE + " WHERE Percent > 0 ORDER BY Percent DESC LIMIT 20");

		while (rs.next()) {
%>
			<tr style="<%= "" /* Province.equals(defaultProvince) ? HILITE_TD : "" */ %>">
				<td class="CellPadding_2px DS-border-dn" valign="top"><%= GEO.getDesc(rs.getString("GeoRef")) %></td>
				<td class="CellPadding_2px DS-border-dn" valign="top" align="right"><%= FmtTool.fmtAmount2dPerc(rs.getDouble("Percent")) %></td>
			</tr>
<%
		}
	
		rs.close();

		st.executeUpdate("DROP TABLE IF EXISTS " + this.TMP_TABLE);

		st.close();
		stUpd.close();

	} catch (Exception e) {
%>
		<tr>
			<td class="CellPadding_3px" colspan="2">
				<div class="DS-text-exception"><%= e.toString() %></div>
			</td>
		</tr>
<%
	}

	DB.destroy();
%>
	</table>
