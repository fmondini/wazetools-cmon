////////////////////////////////////////////////////////////////////////////////////////////////////
//
// City.java
//
// DB Interface for the cities table
//
// First Release: Jan/2013 by Fulvio Mondini (fmondini[at]danisoft.net)
//       Revised: Mar/2025 Ported to Waze dslib.jar
//
////////////////////////////////////////////////////////////////////////////////////////////////////

package net.danisoft.wazetools.cmon;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.Vector;

import net.danisoft.dslib.FmtTool;

/**
 * DB Interface for the cities table
 */
public class City {

	private final static String TBL_NAME = "CMON_cities";

	public static String getTblName() { return TBL_NAME; }

	private Connection cn;

	/**
	 * Constructor
	 */
	public City(Connection conn) {
		this.cn = conn;
	}

	/**
	 * City Data
	 */
	public class Data {

		// Fields
		private int			_ID;				// `CTY_ID` int NOT NULL AUTO_INCREMENT,
		private String		_GeoRef;			// `CTY_GeoRef` varchar(255) NOT NULL DEFAULT '',
		private int			_Province;			// `CTY_Province` int NOT NULL DEFAULT '0',
		private String		_Name;				// `CTY_Name` varchar(255) NOT NULL DEFAULT '',
		private double		_Lat;				// `CTY_Lat` double(10,7) NOT NULL DEFAULT '0.0000000',
		private double		_Lng;				// `CTY_Lng` double(10,7) NOT NULL DEFAULT '0.0000000',
		private int			_Pop;				// `CTY_Pop` int NOT NULL DEFAULT '0',
		private String		_Editor;			// `CTY_Editor` varchar(255) NOT NULL DEFAULT '',
		private double		_Area;				// `CTY_Area` double(7,2) NOT NULL DEFAULT '0.00',
		private int			_StreetNamesP;		// `CTY_StreetNamesP` int NOT NULL DEFAULT '0',
		private int			_StreetNumbersP;	// `CTY_StreetNumbersP` int NOT NULL DEFAULT '0',
		private int			_GasStationsP;		// `CTY_GasStationsP` int NOT NULL DEFAULT '0',
		private int			_ParkingLotsP;		// `CTY_ParkingLotsP` int NOT NULL DEFAULT '0',
		private int			_LandmarksP;		// `CTY_LandmarksP` int NOT NULL DEFAULT '0',
		private int			_NodesCheckP;		// `CTY_NodesCheckP` int NOT NULL DEFAULT '0',
		private int			_LockP;				// `CTY_LockP` int NOT NULL DEFAULT '0',
		private String		_Notes;				// `CTY_Notes` varchar(255) NOT NULL DEFAULT '',
		private Timestamp	_LastUpdated;		// `CTY_LastUpdated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
		private String		_LastUpdatedBy;		// `CTY_LastUpdatedBy` varchar(255) NOT NULL DEFAULT '',
		private String		_Shape;				// `CTY_Shape` polygon DEFAULT NULL,

		// Getters
		public int			getID()				{ return this._ID;				}
		public String		getGeoRef()			{ return this._GeoRef;			}
		public int			getProvince()		{ return this._Province;		}
		public String		getName()			{ return this._Name;			}
		public double		getLat()			{ return this._Lat;				}
		public double		getLng()			{ return this._Lng;				}
		public int			getPop()			{ return this._Pop;				}
		public String		getEditor()			{ return this._Editor;			}
		public double		getArea()			{ return this._Area;			}
		public int			getStreetNamesP() 	{ return this._StreetNamesP;	}
		public int			getStreetNumbersP()	{ return this._StreetNumbersP;	}
		public int			getGasStationsP()	{ return this._GasStationsP;	}
		public int			getParkingLotsP()	{ return this._ParkingLotsP;	}
		public int			getLandmarksP()		{ return this._LandmarksP;		}
		public int			getNodesCheckP()	{ return this._NodesCheckP;		}
		public int			getLockP()			{ return this._LockP;			}
		public String		getNotes()			{ return this._Notes;			}
		public Timestamp	getLastUpdated()	{ return this._LastUpdated;		}
		public String		getLastUpdatedBy()	{ return this._LastUpdatedBy;	}
		public String		getShape()			{ return this._Shape;			}

		// Setters
		public void setID(int id)							{ this._ID = id;							}
		public void setGeoRef(String geoRef)				{ this._GeoRef = geoRef;					}
		public void setProvince(int province)				{ this._Province = province;				}
		public void setName(String name)					{ this._Name = name;						}
		public void setLat(double lat)						{ this._Lat = lat;							}
		public void setLng(double lng)						{ this._Lng = lng;							}
		public void setPop(int pop)							{ this._Pop = pop;							}
		public void setEditor(String editor)				{ this._Editor = editor;					}
		public void setArea(double area)					{ this._Area = area;						}
		public void setStreetNamesP(int streetNamesP)		{ this._StreetNamesP = streetNamesP;		}
		public void setStreetNumbersP(int streetNumbersP)	{ this._StreetNumbersP = streetNumbersP;	}
		public void setGasStationsP(int gasStationsP)		{ this._GasStationsP = gasStationsP;		}
		public void setParkingLotsP(int parkingLotsP)		{ this._ParkingLotsP = parkingLotsP;		}
		public void setLandmarksP(int landmarksP)			{ this._LandmarksP = landmarksP;			}
		public void setNodesCheckP(int nodesCheckP)			{ this._NodesCheckP = nodesCheckP;			}
		public void setLockP(int lockP)						{ this._LockP = lockP;						}
		public void setNotes(String notes)					{ this._Notes = notes;						}
		public void setLastUpdated(Timestamp lastUpdated)	{ this._LastUpdated = lastUpdated;			}
		public void setLastUpdatedBy(String lastUpdatedBy)	{ this._LastUpdatedBy = lastUpdatedBy;		}
		public void setShape(String shape)					{ this._Shape = shape;						}

		/**
		 * Constructor
		 */
		public Data() {
			super();

			this._ID				= 0;
			this._GeoRef			= "";
			this._Province			= 0;
			this._Name				= "";
			this._Lat				= 0.0D;
			this._Lng				= 0.0D;
			this._Pop				= 0;
			this._Editor			= "";
			this._Area				= 0.0D;
			this._StreetNamesP		= 0;
			this._StreetNumbersP	= 0;
			this._GasStationsP		= 0;
			this._ParkingLotsP		= 0;
			this._LandmarksP		= 0;
			this._NodesCheckP		= 0;
			this._LockP				= 0;
			this._Notes				= "";
			this._LastUpdated		= FmtTool.DATEZERO;
			this._LastUpdatedBy		= "";
			this._Shape				= "";
		}
	}

	/**
	 * Read a City
	 */
	public Data Read(int CtyID) {
		return(
			_read_obj_by_id(CtyID)
		);
	}

	/**
	 * Update a City record
	 * @throws Exception
	 */
	public void Update(int CtyID, Data ctyData) throws Exception {

		Statement st = this.cn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);
		ResultSet rs = st.executeQuery("SELECT * FROM " + TBL_NAME + " WHERE CTY_ID = " + CtyID);

		if (rs.next()) {

			_update_rs_from_obj(rs, ctyData);
			rs.updateRow();

		} else
			throw new Exception("CtyID " + CtyID + " NOT found");

		rs.close();
		st.close();
	}

	/**
	 * Get All Cities
	 */
	public Vector<Data> getAll(double latMin, double latMax, double lngMin, double lngMax, int zoomLevel) {

		int minCityPop;
		String Where = "";

		if (latMin != 0.0 | latMax != 0.0 | lngMin != 0.0 | lngMax != 0.0)
			Where = "(CTY_Lat BETWEEN " + latMin + " AND " + latMax + ") AND (CTY_Lng BETWEEN " + lngMin + " AND " + lngMax + ")";

		if (zoomLevel <=  7) minCityPop =  200000; else
		if (zoomLevel <=  8) minCityPop =  100000; else
		if (zoomLevel <=  9) minCityPop =   75000; else
		if (zoomLevel <= 10) minCityPop =   50000; else
		if (zoomLevel <= 11) minCityPop =       0; else
							 minCityPop =       0;

		if (minCityPop > 0)
			Where += (Where.equals("") ? "" : " AND ") + "(CTY_Pop > " + minCityPop + ")";

		if (!Where.equals(""))
			Where = " WHERE ".concat(Where);

		return(
			_fill_cty_vector(
				"SELECT *, ST_AsText(CTY_Shape) AS TextShape " +
				"FROM " + TBL_NAME +
				Where + " " +
				"ORDER BY CTY_name;"
			)
		);
	}

	/**
	 * Get Editors Combo
	 */
	public String getEditorsCombo(String selected) {

		final String TMP_TABLE = "CMON_tmpEditors";

		String Editor, rawEditors, Tokens[], Results = "";
		
		try {

			Statement stInp = this.cn.createStatement();
			Statement stOut = this.cn.createStatement();
			Statement stDel = this.cn.createStatement();

			ResultSet rsInp;
			
			// Filter editors

			stDel.execute("DROP TABLE IF EXISTS " + TMP_TABLE);

			stOut.execute(
				"CREATE TABLE " + TMP_TABLE + " (" +
					"Editor varchar(255) NOT NULL DEFAULT '', " +
					"PRIMARY KEY (Editor) " +
				") ENGINE=InnoDB;"
			);

			rsInp = stInp.executeQuery("SELECT DISTINCT CTY_Editor FROM " + TBL_NAME + " WHERE CTY_Editor != '' ORDER BY CTY_Editor;");

			while (rsInp.next()) {

				rawEditors = rsInp.getString("CTY_Editor");

				if (rawEditors.contains(",")) {
					
					Tokens = rawEditors.split(",");

					for (int i=0; i<Tokens.length; i++) {

						Editor = Tokens[i].trim();

						try {
							stOut.execute("INSERT INTO " + TMP_TABLE + " VALUES ('" + Editor + "');");
						} catch (Exception ee) { } // Skip dupes
					}
				}
			}

			rsInp.close();
			stOut.close();

			// Create combo

			rsInp = stInp.executeQuery("SELECT DISTINCT Editor FROM " + TMP_TABLE + " ORDER BY Editor;");

			while (rsInp.next()) {

				Editor = rsInp.getString("Editor");
				Results += "<option value=\"" + Editor + "\" " + (Editor.equals(selected) ? "selected" : "") + ">" + Editor + "</option>";
			}

			rsInp.close();
			stInp.close();

			stDel.execute("DROP TABLE IF EXISTS " + TMP_TABLE);
			stDel.close();

		} catch (Exception e) {
			Results = "<option value=\"value\" selected>" + e.toString() + "</option>";
		}

		return(Results);
	}

	/**
	 * Get completion percent based on fields values
	 */
	public static double getCompletionPercent(double nodcp, double snamp, double snump, double gaspl, double plotp, double lmrkp, double lockp) {

		final double MULT_NODCP = 10.0D; // Nodes Check
		final double MULT_SNAMP = 10.0D; // Street Names
		final double MULT_SNUMP =  0.0D; // Street Numbers
		final double MULT_GASPL = 10.0D; // Gas Stations
		final double MULT_PLOTP =  1.0D; // Parking Lots
		final double MULT_LMRKP =  1.0D; // Landmarks
		final double MULT_LOCKP =  5.0D; // Objects Lock

		final double MULT_MAX_VALUE = (MULT_NODCP + MULT_SNAMP + MULT_SNUMP + MULT_GASPL + MULT_PLOTP + MULT_LMRKP + MULT_LOCKP) * 100.0;

		double VAL_NODCP = MULT_NODCP * nodcp;
		double VAL_SNAMP = MULT_SNAMP * snamp;
		double VAL_SNUMP = MULT_SNUMP * snump;
		double VAL_GASPL = MULT_GASPL * gaspl;
		double VAL_PLOTP = MULT_PLOTP * plotp;
		double VAL_LMRKP = MULT_LMRKP * lmrkp;
		double VAL_LOCKP = MULT_LOCKP * lockp;

		return(FmtTool.Round(((VAL_NODCP + VAL_SNAMP + VAL_SNUMP + VAL_GASPL + VAL_PLOTP + VAL_LMRKP + VAL_LOCKP) / MULT_MAX_VALUE) * 100.0, 2));
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////
	//
	// +++ PRIVATE +++
	//
	////////////////////////////////////////////////////////////////////////////////////////////////////

	/**
	 * Read CTY Record based on given ID
	 * @return <City.Data> result 
	 */
	private Data _read_obj_by_id(int CtyID) {

		Data data = new Data();

		try {
			
			Statement st = this.cn.createStatement();
			ResultSet rs = st.executeQuery("SELECT *, ST_AsText(CTY_Shape) AS TextShape FROM " + TBL_NAME + " WHERE CTY_ID = " + CtyID + ";");

			if (rs.next())
				data = _parse_obj_from_rs(rs);

			rs.close();
			st.close();

		} catch (Exception e) { }

		return(data);
	}

	/**
	 * Parse a given ResultSet into a CtyObject object
	 * @return <City.Data> result 
	 */
	private Data _parse_obj_from_rs(ResultSet rs) {

		Data data = new Data();

		try {
			
			data.setID(rs.getInt("CTY_ID"));
			data.setGeoRef(rs.getString("CTY_GeoRef"));
			data.setProvince(rs.getInt("CTY_Province"));
			data.setName(rs.getString("CTY_Name"));
			data.setLat(rs.getDouble("CTY_Lat"));
			data.setLng(rs.getDouble("CTY_Lng"));
			data.setPop(rs.getInt("CTY_Pop"));
			data.setEditor(rs.getString("CTY_Editor"));
			data.setArea(rs.getDouble("CTY_Area"));
			data.setStreetNamesP(rs.getInt("CTY_StreetNamesP"));
			data.setStreetNumbersP(rs.getInt("CTY_StreetNumbersP"));
			data.setGasStationsP(rs.getInt("CTY_GasStationsP"));
			data.setParkingLotsP(rs.getInt("CTY_ParkingLotsP"));
			data.setLandmarksP(rs.getInt("CTY_LandmarksP"));
			data.setNodesCheckP(rs.getInt("CTY_NodesCheckP"));
			data.setLockP(rs.getInt("CTY_LockP"));
			data.setNotes(rs.getString("CTY_Notes"));
			data.setLastUpdated(rs.getTimestamp("CTY_LastUpdated"));
			data.setLastUpdatedBy(rs.getString("CTY_LastUpdatedBy"));
			data.setShape(rs.getString("TextShape"));

		} catch (Exception e) { }

		return(data);
	}

	/**
	 * Update a given ResultSet from a given City.Data object
	 */
	private static void _update_rs_from_obj(ResultSet rs, Data data) {

		try {
			
			rs.updateString("CTY_GeoRef", data.getGeoRef());
			rs.updateInt("CTY_Province", data.getProvince());
			rs.updateString("CTY_Name", data.getName());
			rs.updateDouble("CTY_Lat", data.getLat());
			rs.updateDouble("CTY_Lng", data.getLng());
			rs.updateInt("CTY_Pop", data.getPop());
			rs.updateString("CTY_Editor", data.getEditor());
			rs.updateDouble("CTY_Area", data.getArea());
			rs.updateInt("CTY_StreetNamesP", data.getStreetNamesP());
			rs.updateInt("CTY_StreetNumbersP", data.getStreetNumbersP());
			rs.updateInt("CTY_GasStationsP", data.getGasStationsP());
			rs.updateInt("CTY_ParkingLotsP", data.getParkingLotsP());
			rs.updateInt("CTY_LandmarksP", data.getLandmarksP());
			rs.updateInt("CTY_NodesCheckP", data.getNodesCheckP());
			rs.updateInt("CTY_LockP", data.getLockP());
			rs.updateString("CTY_Notes", data.getNotes());
			try { rs.updateTimestamp("CTY_LastUpdated", data.getLastUpdated()); } catch (Exception e) { }
			rs.updateString("CTY_LastUpdatedBy", data.getLastUpdatedBy());

		} catch (Exception e) { }

	}

	/**
	 * Read CTY Records based on given query
	 * @return Vector<City.Data> of results 
	 */
	private Vector<Data> _fill_cty_vector(String query) {

		Vector<Data> vecData = new Vector<Data>();

		try {
			
			Statement st = this.cn.createStatement();
			ResultSet rs = st.executeQuery(query);

			while (rs.next())
				vecData.add(_parse_obj_from_rs(rs));

			rs.close();
			st.close();

		} catch (Exception e) { }

		return(vecData);
	}

}
