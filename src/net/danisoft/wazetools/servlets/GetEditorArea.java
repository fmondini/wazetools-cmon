////////////////////////////////////////////////////////////////////////////////////////////////////
//
// GetEditorArea.java
//
// Servlet to get all city polygons for a given user (in POLYGON((..)) format)
//
// First Release: Mar/2013 by Fulvio Mondini (fmondini[at]danisoft.net)
//       Revised: Aug/2021 by Fulvio Mondini (fmondini[at]danisoft.net)
//       Revised: Mar/2025 Ported to Waze dslib.jar
//                         Changed to @WebServlet style
//
////////////////////////////////////////////////////////////////////////////////////////////////////

package net.danisoft.wazetools.servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.ResultSet;
import java.sql.Statement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONObject;

import net.danisoft.dslib.Database;
import net.danisoft.dslib.EnvTool;
import net.danisoft.dslib.FmtTool;
import net.danisoft.dslib.SysTool;

@WebServlet(description = "Get all city polygons for a given user (in POLYGON((..)) format)", urlPatterns = { "/servlet/GetEditorArea" })

public class GetEditorArea extends HttpServlet {

	private static final long serialVersionUID = FmtTool.getSerialVersionUID();

	@Override
	public void doGet(final HttpServletRequest request, final HttpServletResponse response) throws ServletException, IOException {

		response.setHeader("Pragma","no-cache"); // HTTP 1.0
		response.setHeader("Cache-Control","no-cache"); // HTTP 1.1
		response.setDateHeader ("Expires", 0); // prevents caching at the proxy server

		response.setContentType("application/json");

		PrintWriter out = response.getWriter();
		JSONObject Result = new JSONObject();

		int i, rc = 0;
		String script = "";
		String UserID = EnvTool.getStr(request, "UserID", "");

		Database DB = null;

		try {

			DB = new Database();
			String ShapeText = "";

			if (UserID.equals(""))
				throw new Exception("Parameters needed");

			// Retrieve User Areas

			Statement AMGR_st = DB.getConnection().createStatement();
			ResultSet AMGR_rs = AMGR_st.executeQuery("SELECT CAST(ST_AsText(AUA_Area) AS CHAR) AS ShapeText FROM AUTH_areas WHERE AUA_User = '" + UserID + "'");

			while (AMGR_rs.next())
				ShapeText += (ShapeText.equals("") ? "" : SysTool.getDelimiter()) + AMGR_rs.getString("ShapeText");

			AMGR_rs.close();
			AMGR_st.close();
			
			if (ShapeText.equals(""))
				throw new Exception("GetEditorArea(): Unable to find editor: '" + UserID + "'");

			String Areas[] = ShapeText.split(SysTool.getDelimiter());

			// Create Script

			script += "function DrawEditorAreas(CurrentMap, CurrentOptions) {\n";
			script += "var EditorAreasLayer = new Microsoft.Maps.Layer();\n";
			script += "Microsoft.Maps.loadModule('Microsoft.Maps.WellKnownText', function () {\n";

			for (i=0; i<Areas.length; i++) {
				script += "Poly = Microsoft.Maps.WellKnownText.read('" + Areas[i].replace("POLYGON", "LINESTRING") + "', CurrentOptions);\n";
				script += "EditorAreasLayer.add(Poly);\n";
			}

			script += "CurrentMap.layers.insert(EditorAreasLayer);\n";
			script += "});\n";
			script += "}\n";

			rc = HttpServletResponse.SC_OK;

		} catch (Exception e) {

			System.err.println(e.toString());
			rc = HttpServletResponse.SC_NOT_ACCEPTABLE;
			script = e.toString();
		}

		if (DB != null)
			DB.destroy();

		try {

			Result.put("rc", rc);
			Result.put("script", script);

		} catch (Exception e) {

			System.err.println(e.toString());
		}

		out.println(Result.toString());

		out.flush();
		out.close();
	}
}
