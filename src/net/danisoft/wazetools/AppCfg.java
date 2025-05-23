////////////////////////////////////////////////////////////////////////////////////////////////////
//
// AppCfg.java
//
// Main application configuration file
//
// First Release: Mar/2025 by Fulvio Mondini (https://danisoft.software/)
//
////////////////////////////////////////////////////////////////////////////////////////////////////

package net.danisoft.wazetools;

import net.danisoft.dslib.AppList;
import net.danisoft.dslib.FmtTool;
import net.danisoft.dslib.SiteCfg;
import net.danisoft.dslib.SysTool;

public class AppCfg {

	////////////////////////////////////////////////////////////////////////////////////////////////////
	//
	// Editable parameters
	//

	private static final int	APP_VERS_MAJ = 6;
	private static final int	APP_VERS_MIN = 0;
	private static final String	APP_VERS_REL = "GA";
	private static final String	APP_DATE_REL = "May 3, 2025";

	private static final String	APP_NAME_TAG = AppList.CMON.getName();
	private static final String	APP_NAME_TXT = "Waze.Tools " + APP_NAME_TAG;
	private static final String	APP_ABSTRACT = "Waze Italian Map Completion Monitor";
	private static final String	APP_EXITLINK = "https://waze.tools/";

	private static final String	SERVER_ROOTPATH_DEVL = "C:/WorkSpace/Eclipse/Waze.Tools/wazetools-cmon/Web Content";
	private static final String	SERVER_ROOTPATH_PROD = "/var/www/html/cmon.waze.tools/Web Content";

	private static final String	SERVER_HOME_URL_DEVL = "http://localhost:8080/cmon.waze.tools";
	private static final String	SERVER_HOME_URL_PROD = "https://cmon.waze.tools";

	// Login stuff
	private static final String	ONLOGOUT_URL = "../home/";

	// MAP stuff
	private static final String	MAP_AREANAME = "Italy";
	private static final String	MAP_CNTNR_ID = "map_canvas";

	////////////////////////////////////////////////////////////////////////////////////////////////////
	//
	// Getters
	//

	public static final String getAppTag()				{ return(APP_NAME_TAG);	}
	public static final String getAppName()				{ return(APP_NAME_TXT);	}
	public static final String getAppAbstract()			{ return(APP_ABSTRACT);	}
	public static final String getAppVersion()			{ return(APP_VERS_MAJ + "." + FmtTool.fmtZeroPad(APP_VERS_MIN, 2) + "." + APP_VERS_REL); }
	public static final String getAppRelDate()			{ return(APP_DATE_REL);	}
	public static final String getAppExitLink()			{ return(APP_EXITLINK);	}
	public static final String getServerRootPath()		{ return(SysTool.isWindog() ? SERVER_ROOTPATH_DEVL : SERVER_ROOTPATH_PROD); }
	public static final String getServerHomeUrl()		{ return(SysTool.isWindog() ? SERVER_HOME_URL_DEVL : SERVER_HOME_URL_PROD); }
	// Login stuff
	public static final String getAuthDefaultUser()		{ return(SysTool.isWindog() ? new SiteCfg().getPrivateParams().getDebugUser() : ""); }
	public static final String getAuthDefaultPass()		{ return(SysTool.isWindog() ? new SiteCfg().getPrivateParams().getDebugPass() : ""); }
	public static final String getAuthOnLogoutUrl()		{ return(ONLOGOUT_URL); }
	// MAP stuff
	public static final String getCoveredAreaName()		{ return(MAP_AREANAME); }
	public static final String getMapContainerId()		{ return(MAP_CNTNR_ID); }
	public static final String getMapActivationKey()	{ return(new SiteCfg().getPrivateParams().getBingMapKey()); }
	public static final String getGMapActvKey() 		{ return(new SiteCfg().getPrivateParams().getGoogleMapKey()); }
}
