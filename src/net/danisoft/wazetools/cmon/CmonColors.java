////////////////////////////////////////////////////////////////////////////////////////////////////
//
// CmonColors.java
//
// STATIC functions & constants for Polygons Colors
//
// First Release: Jan/2013 by Fulvio Mondini (fmondini[at]danisoft.net)
//       Revised: Jan/2024 Moved to V3
//       Revised: Mar/2025 Ported to Waze dslib.jar
//
////////////////////////////////////////////////////////////////////////////////////////////////////

package net.danisoft.wazetools.cmon;

import java.awt.Color;

/**
 * CMON Polygons Colors
 */
public class CmonColors {
	
	public static final int STEP_1_5_PERCENT =   0; public static final String STEP_1_5_INTERNAL = "#ff0000"; public static final String STEP_1_5_EXTERNAL = "#c40000";
	public static final int STEP_2_5_PERCENT =  25; public static final String STEP_2_5_INTERNAL = "#f6b26b"; public static final String STEP_2_5_EXTERNAL = "#e87400";
	public static final int STEP_3_5_PERCENT =  50; public static final String STEP_3_5_INTERNAL = "#ffff00"; public static final String STEP_3_5_EXTERNAL = "#808040";
	public static final int STEP_4_5_PERCENT =  75; public static final String STEP_4_5_INTERNAL = "#93c47d"; public static final String STEP_4_5_EXTERNAL = "#008080";
	public static final int STEP_5_5_PERCENT = 100; public static final String STEP_5_5_INTERNAL = "#00ff00"; public static final String STEP_5_5_EXTERNAL = "#008000";

	/**
	 * Return Fill (Internal) Color based on value (0/100)
	 */
	public static String getFill(int Percent) {
		return (
			Percent == STEP_5_5_PERCENT ? STEP_5_5_INTERNAL : (
				Percent >= STEP_4_5_PERCENT ? STEP_4_5_INTERNAL : (
					Percent >= STEP_3_5_PERCENT ? STEP_3_5_INTERNAL : (
						Percent >= STEP_2_5_PERCENT ? STEP_2_5_INTERNAL : (
							STEP_1_5_INTERNAL
						)
					)
				)
			)
		);
	}

	/**
	 * Return Stroke (External) Color based on value (0/100)
	 */
	public static String getStroke(int Percent) {
		return (
			Percent == STEP_5_5_PERCENT ? STEP_5_5_EXTERNAL : (
				Percent >= STEP_4_5_PERCENT ? STEP_4_5_EXTERNAL : (
					Percent >= STEP_3_5_PERCENT ? STEP_3_5_EXTERNAL : (
						Percent >= STEP_2_5_PERCENT ? STEP_2_5_EXTERNAL : (
							STEP_1_5_EXTERNAL
						)
					)
				)
			)
		);
	}

	/**
	 * Convert colors from #xxyyzz notation to RGB notation (r,g,b)
	 */
	public static String Hex2Rgb(String HexColor) {
		return(
			Color.decode(HexColor).getRed() + "," +
			Color.decode(HexColor).getGreen() + "," +
			Color.decode(HexColor).getBlue()
		);
	}

}
