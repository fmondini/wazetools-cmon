<%@ page
	language="java"
	contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="java.sql.*"
	import="java.util.*"
	import="net.danisoft.dslib.*"
	import="net.danisoft.wazetools.cmon.*"
%>
<%!
	final String TMP_TABLE = "CMON_tmpStats_EDT";
%>
	<div class="DS-text-black DS-back-gray DS-border-dn DS-padding-3px" align="center">TOP 20 Editors</div>

	<table class="TableSpacing_0px DS-full-width DS-text-compact">
<%
	Database DB = new Database();

	Statement st = DB.getConnection().createStatement();
	Statement stUpd = DB.getConnection().createStatement();
	ResultSet rs = null;

	try {

		st.executeUpdate("DROP TABLE IF EXISTS " + this.TMP_TABLE);

		st.executeUpdate(
			"CREATE TABLE " + this.TMP_TABLE + " (" +
				"Editor varchar(255) NOT NULL, " +
				"Count decimal(7,2) NOT NULL DEFAULT '0.00', " +
				"StreetNamesP decimal(7,2) DEFAULT NULL, " +
				"StreetNumbersP decimal(7,2) DEFAULT NULL, " +
				"GasStationsP decimal(7,2) DEFAULT NULL, " +
				"ParkingLotsP decimal(7,2) DEFAULT NULL, " +
				"LandmarksP decimal(7,2) DEFAULT NULL, " +
				"NodesCheckP decimal(7,2) DEFAULT NULL, " +
				"LockP decimal(7,2) DEFAULT NULL, " +
				"Percent decimal(7,2) NOT NULL DEFAULT '0.00', " +
				"PRIMARY KEY (Editor)" +
			") ENGINE=InnoDB;"
		);

		st.executeUpdate(
			"INSERT INTO " + this.TMP_TABLE + " (" +
				"Editor, Count, StreetNamesP, StreetNumbersP, GasStationsP, ParkingLotsP, LandmarksP, NodesCheckP, LockP, Percent" +
			") SELECT " +
				"CTY_Editor, " +
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
			"GROUP BY CTY_Editor " +
			"HAVING CTY_Editor <> ''"
		);

		rs = st.executeQuery("SELECT * FROM " + this.TMP_TABLE);

		int i;
		String EdtName;
		String Tokens[];
		double newPercent;

		while (rs.next()) {

			EdtName = rs.getString("Editor");
			
			if (EdtName.contains(",")) {

				Tokens = EdtName.split(",");
				
				for (i=0; i<Tokens.length; i++) {

					try {

						stUpd.executeUpdate(
							"INSERT INTO " + this.TMP_TABLE + " (" +
								"Editor, Count, StreetNamesP, StreetNumbersP, GasStationsP, ParkingLotsP, LandmarksP, NodesCheckP, LockP" +
							") VALUES(" +
								"'" + Tokens[i].trim() + "', " +
								rs.getDouble("Count") + ", " +
								rs.getDouble("StreetNamesP") + ", " +
								rs.getDouble("StreetNumbersP") + ", " +
								rs.getDouble("GasStationsP") + ", " +
								rs.getDouble("ParkingLotsP") + ", " +
								rs.getDouble("LandmarksP") + ", " +
								rs.getDouble("NodesCheckP") + ", " +
								rs.getDouble("LockP") +
							")"
						);

					} catch (SQLIntegrityConstraintViolationException e) {

						stUpd.executeUpdate(
							"UPDATE " + this.TMP_TABLE + " SET " +
								"Count = Count + " + rs.getDouble("Count") + ", " +
								"StreetNamesP = StreetNamesP + " + rs.getDouble("StreetNamesP") + ", " +
								"StreetNumbersP = StreetNumbersP + " + rs.getDouble("StreetNumbersP") + ", " +
								"GasStationsP = GasStationsP + " + rs.getDouble("GasStationsP") + ", " +
								"ParkingLotsP = ParkingLotsP + " + rs.getDouble("ParkingLotsP") + ", " +
								"LandmarksP = LandmarksP + " + rs.getDouble("LandmarksP") + ", " +
								"NodesCheckP = NodesCheckP + " + rs.getDouble("NodesCheckP") + ", " +
								"LockP = LockP + " + rs.getDouble("LockP") + " " +
							"WHERE Editor = '" + Tokens[i].trim() + "'"
						);
					}
				}
			}
		}

		rs.close();

		stUpd.executeUpdate("DELETE FROM " + this.TMP_TABLE + " WHERE EDITOR LIKE '%,%'");

		st.executeUpdate("UPDATE " + this.TMP_TABLE + " SET StreetNamesP = StreetNamesP / Count");
		st.executeUpdate("UPDATE " + this.TMP_TABLE + " SET StreetNumbersP = StreetNumbersP / Count");
		st.executeUpdate("UPDATE " + this.TMP_TABLE + " SET GasStationsP = GasStationsP / Count");
		st.executeUpdate("UPDATE " + this.TMP_TABLE + " SET ParkingLotsP = ParkingLotsP / Count");
		st.executeUpdate("UPDATE " + this.TMP_TABLE + " SET LandmarksP = LandmarksP / Count");
		st.executeUpdate("UPDATE " + this.TMP_TABLE + " SET NodesCheckP = NodesCheckP / Count");
		st.executeUpdate("UPDATE " + this.TMP_TABLE + " SET LockP = LockP / Count");

		rs = st.executeQuery("SELECT * FROM " + this.TMP_TABLE);

		while (rs.next()) {

			EdtName = rs.getString("Editor");

			newPercent = City.getCompletionPercent(
				rs.getDouble("NodesCheckP"),
				rs.getDouble("StreetNamesP"),
				rs.getDouble("StreetNumbersP"),
				rs.getDouble("GasStationsP"),
				rs.getDouble("ParkingLotsP"),
				rs.getDouble("LandmarksP"),
				rs.getDouble("LockP")
			);

			stUpd.executeUpdate("UPDATE " + this.TMP_TABLE + " SET Percent = " + newPercent + " WHERE Editor = '" + EdtName.replace("'", "\\'") + "'");
		}

		rs.close();

		// Read

		rs = st.executeQuery("SELECT * FROM " + this.TMP_TABLE + " WHERE Percent > 0 ORDER BY Percent DESC LIMIT 20");

		while (rs.next()) {
		
			EdtName = rs.getString("EDITOR");
%>
			<tr style="<%= "" /* EdtName.equals(UserLogin) ? HILITE_TD : "" */ %>">
				<td class="CellPadding_2px DS-border-dn" valign="top"><a href="details.jsp?reqEditor=<%= EdtName %>"><%= EdtName %></a></td>
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
