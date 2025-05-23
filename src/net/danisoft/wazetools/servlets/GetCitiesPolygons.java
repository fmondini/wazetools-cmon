////////////////////////////////////////////////////////////////////////////////////////////////////
//
// GetCitiesPolygons.java
//
// Servlet to retrieve city polygons by LAT/LNG viewport
//
// First Release: Jan/2013 by Fulvio Mondini (fmondini[at]danisoft.net)
//       Revised: Aug/2021 by Fulvio Mondini (fmondini[at]danisoft.net)
//       Revised: Mar/2025 Ported to Waze dslib.jar
//                         Changed to @WebServlet style
//
////////////////////////////////////////////////////////////////////////////////////////////////////

package net.danisoft.wazetools.servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Vector;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.danisoft.dslib.Database;
import net.danisoft.dslib.EnvTool;
import net.danisoft.dslib.FmtTool;
import net.danisoft.wazetools.cmon.City;

@WebServlet(description = "Retrieve city polygons by LAT/LNG viewport", urlPatterns = { "/servlet/GetCitiesPolygons" })

public class GetCitiesPolygons extends HttpServlet {

	private static final long serialVersionUID = FmtTool.getSerialVersionUID();

	private static final double VIEWPORT_LAT_TOLERANCE = 0.002;
	private static final double VIEWPORT_LNG_TOLERANCE = 0.01;

	@Override
	public void doPost(final HttpServletRequest request, final HttpServletResponse response) throws ServletException, IOException {

		PrintWriter out = response.getWriter();

		double latMin = EnvTool.getDbl(request, "latMin", 0.0) * (1 - VIEWPORT_LAT_TOLERANCE);
		double latMax = EnvTool.getDbl(request, "latMax", 0.0) * (1 + VIEWPORT_LAT_TOLERANCE);
		double lngMin = EnvTool.getDbl(request, "lngMin", 0.0) * (1 - VIEWPORT_LNG_TOLERANCE);
		double lngMax = EnvTool.getDbl(request, "lngMax", 0.0) * (1 + VIEWPORT_LNG_TOLERANCE);
		int zoomLevel = EnvTool.getInt(request, "zoomLevel", 0);

		Database DB = null;

		try {

			DB = new Database();
			City CTY = new City(DB.getConnection());

			Vector<City.Data> vecCtyData = CTY.getAll(latMin, latMax, lngMin, lngMax, zoomLevel);

			out.println("function getCityPolygons() {");
			out.println("citypolygons = {};");

			for (City.Data ctyData : vecCtyData) {
				out.println(
					"citypolygons[" + ctyData.getID() + "] = {" +
						"id:" + ctyData.getID() + ", " +
						"name:'" + ctyData.getName().replace("'", "\\'") + "', " +
						"center:new Microsoft.Maps.Location(" + FmtTool.Round(ctyData.getLat(), 3) + ", " + FmtTool.Round(ctyData.getLng(), 3) + "), " +
						"population:" + ctyData.getPop() + ", " +
						"area:" + ctyData.getArea() + ", " +
						"editor:'" + (ctyData.getEditor().equals("") ? "unknown" : ctyData.getEditor()) + "', " +
						"snamp:" + ctyData.getStreetNamesP() + ", " +
						"snump:" + ctyData.getStreetNumbersP() + ", " +
						"gasp:" + ctyData.getGasStationsP() + ", " +
						"plotp:" + ctyData.getParkingLotsP() + ", " +
						"lmrkp:" + ctyData.getLandmarksP() + ", " +
						"nodcp:" + ctyData.getNodesCheckP() + ", " +
						"lockp:" + ctyData.getLockP() + ", " +
						"percent:" + City.getCompletionPercent(ctyData.getNodesCheckP(), ctyData.getStreetNamesP(), ctyData.getStreetNumbersP(), ctyData.getGasStationsP(), ctyData.getParkingLotsP(), ctyData.getLandmarksP(), ctyData.getLockP()) + ", " +
						"poly:'" + ctyData.getShape() + "', " +
						"lastupd:'" + FmtTool.fmtDateTime(ctyData.getLastUpdated()) + "', " +
						"lastupdby:'" + (ctyData.getLastUpdatedBy().equals("") ? "system" : ctyData.getLastUpdatedBy()) + "'" +
					"};"
				);
			}

			out.println("return(citypolygons);");
			out.println("}");

		} catch (Exception e) {

			System.err.println(e.toString());
			response.sendError(HttpServletResponse.SC_NOT_ACCEPTABLE, "\n\nGetCitiesPolygons Servlet Error\n" + e.toString());
		}

		if (DB != null)
			DB.destroy();

		out.flush();
		out.close();
	}

}
