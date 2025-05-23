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
	private final String TMP_TABLE = "CMON_tmpStats_ARE";
%>
	<div class="DS-text-black DS-back-gray DS-border-dn DS-padding-3px" align="center">TOP 20 Editors by Area</div>

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
				"Area decimal(7,2) NOT NULL DEFAULT '0.00', " +
				"PRIMARY KEY (Editor)" +
			") ENGINE=InnoDB;"
		);

		st.executeUpdate(
			"INSERT INTO " + this.TMP_TABLE + " (" +
				"Editor, Area" +
			") SELECT " +
				"CTY_Editor, " +
				"ROUND(SUM(CTY_Area), 2) " +
			"FROM " + City.getTblName() + " " +
			"GROUP BY CTY_Editor " +
			"HAVING CTY_Editor <> ''"
		);

		int i;
		String EdtName;
		String Tokens[];

		rs = st.executeQuery("SELECT * FROM " + this.TMP_TABLE);

		while (rs.next()) {

			EdtName = rs.getString("Editor");

			if (EdtName.contains(",")) {

				Tokens = EdtName.split(",");

				for (i=0; i<Tokens.length; i++) {

					try {

						stUpd.executeUpdate(
							"INSERT INTO " + this.TMP_TABLE + " (" +
								"Editor, Area" +
							") VALUES(" +
								"'" + Tokens[i].trim() + "', " +
								rs.getDouble("Area") +
							")"
						);

					} catch (SQLIntegrityConstraintViolationException e) {

						stUpd.executeUpdate(
							"UPDATE " + this.TMP_TABLE + " " +
							"SET Area = Area + " + rs.getDouble("Area") + " " +
							"WHERE Editor = '" + Tokens[i].trim() + "'"
						);
					}
				}
			}
		}

		rs.close();
		
		stUpd.executeUpdate("DELETE FROM " + this.TMP_TABLE + " WHERE Editor LIKE '%,%'");

		rs = st.executeQuery("SELECT * FROM " + this.TMP_TABLE + " ORDER BY Area DESC LIMIT 20");

		while (rs.next()) {

			EdtName = rs.getString("Editor");
%>
			<tr style="<%= "" /* EdtName.equals(UserLogin) ? HILITE_TD : "" */ %>">
				<td class="CellPadding_2px DS-border-dn" valign="top"><a href="details.jsp?reqEditor=<%= EdtName %>"><%= EdtName %></a></td>
				<td class="CellPadding_2px DS-border-dn" valign="top" align="right"><%= FmtTool.fmtNumber0dUS(rs.getDouble("Area")) %>&nbsp;Km&sup2;</td>
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
