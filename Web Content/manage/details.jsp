<%@ page
	language="java"
	contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="net.danisoft.dslib.*"
	import="net.danisoft.wazetools.cmon.*"
%>
<%!
	private static final String PAGE_Title = "Cities Details Report";
	private static final String PAGE_Keywords = "";
	private static final String PAGE_Description = "";

	private static final String DETAILS_REQ_EDITOR = "CMON_DETAILS_reqEditor";
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

	/**
	 * Get Country List
	 */
	function getCouList(destDiv, CouDivToClick, RegDivToClick, PrvDivToClick) {

		$('#' + destDiv).html('<img border="0" src="../images/ajax-loader.gif">');

		$.ajax({

			type: "POST",
			cache: false,
			url: '_inc_details_cou.jsp',

			data: {
				RegDivToClick: RegDivToClick,
				PrvDivToClick: PrvDivToClick
			},

			success: function(data) {
				$('#' + destDiv).html(data);
			},

			error: function(XMLHttpRequest, textStatus, errorThrown) {
				$('#' + destDiv).html('getCouList() ERROR ' + XMLHttpRequest.status + ': ' + XMLHttpRequest.statusText);
			},

			complete: function(jqXHR, textStatus) {
				if (!CouDivToClick == '')
					$('#' + CouDivToClick).trigger('click');
			}
		});
	}

	/**
	 * Get Region List
	 */
	function getRegList(destDiv, parentCode, RegDivToClick, PrvDivToClick) {

		$('#' + destDiv).html('<img border="0" src="../images/ajax-loader.gif">');

		$.ajax({

			type: "POST",
			cache: false,
			url: '_inc_details_reg.jsp',

			data: {
				parentCode: parentCode,
				PrvDivToClick: PrvDivToClick
			},

			success: function(data) {
				$('#' + destDiv).html(data);
			},

			error: function(XMLHttpRequest, textStatus, errorThrown) {
				$('#' + destDiv).html('getRegList() ERROR ' + XMLHttpRequest.status + ': ' + XMLHttpRequest.statusText);
			},

			complete: function(jqXHR, textStatus) {
				if (!RegDivToClick== '')
					$('#' + RegDivToClick).trigger('click');
			}
		});
	}

	/**
	 * Get Province List
	 */
	function getPrvList(destDiv, parentCode, PrvDivToClick) {

		$('#' + destDiv).html('<img border="0" src="../images/ajax-loader.gif">');

		$.ajax({

			type: "POST",
			cache: false,
			url: '_inc_details_prv.jsp',

			data: {
				parentCode: parentCode
			},

			success: function(data) {
				$('#' + destDiv).html(data);
			},

			error: function(XMLHttpRequest, textStatus, errorThrown) {
				$('#' + destDiv).html('<span class="DS-text-exception">getPrvList() ERROR ' + XMLHttpRequest.status + '</span>: ' + XMLHttpRequest.statusText);
			},

			complete: function(jqXHR, textStatus) {
				if (!PrvDivToClick== '')
					$('#' + PrvDivToClick).trigger('click');
			}
		});
	}

	/**
	 * Get City List
	 */
	function getCtyList(destDiv, parentCode, NicknameFilter) {

		$('#' + destDiv).html('<img border="0" src="../images/ajax-loader.gif">');

		$.ajax({

			type: "POST",
			cache: false,
			url: '_inc_details_cty.jsp',

			data: {
				parentCode: parentCode,
				NicknameFilter: NicknameFilter
			},

			success: function(data) {
				$('#' + destDiv).html(data);
			},

			error: function(XMLHttpRequest, textStatus, errorThrown) {
				$('#' + destDiv).html('<span class="DS-text-exception">getPrvList() ERROR ' + XMLHttpRequest.status + '</span>: ' + XMLHttpRequest.statusText);
			}
		});
	}

	/**
	 * Get City Modification History
	 */
	function getHistory(CityID, CityName) {

		var AlertText = '';

		$.ajax({

			type: "POST",
			cache: false,
			url: '_inc_popup_history.jsp',

			data: {
				CityID: CityID
			},

			success: function(data) {
				AlertText = data;
			},

			error: function(XMLHttpRequest, textStatus, errorThrown) {
				AlertText = 'getHistory() ERROR ' + XMLHttpRequest.status + ': ' + XMLHttpRequest.statusText;
			},

			complete: function(jqXHR, textStatus) {
				
 				ShowDialog_OK(
 					'<b>' + CityName + '</b> - Modification History',
					AlertText,
					'OK'
				);
			}
		});
	}

	/**
	 * Get City Notes
	 */
	function getNotes(CityID, CityName) {

		var AlertText = '';

		$.ajax({

			type: "POST",
			cache: false,
			url: '_inc_popup_notes.jsp',

			data: {
				CityID: CityID
			},

			success: function(data) {
				AlertText = data;
			},

			error: function(XMLHttpRequest, textStatus, errorThrown) {
				AlertText = 'getNotes() ERROR ' + XMLHttpRequest.status + ': ' + XMLHttpRequest.statusText;
			},

			complete: function(jqXHR, textStatus) {
 				ShowDialog_OK(
 					'<b>' + CityName + '</b> - Notes',
 					AlertText,
					'OK'
				);
			}
		});
	}

	</script>

</head>

<body>

	<jsp:include page="../_common/header.jsp" />

	<div class="mdc-layout-grid DS-layout-body">
	<div class="mdc-layout-grid__inner">
	<div class="<%= MdcTool.Layout.Cell(12, 8, 4) %>">
<%
	String RedirectTo = "";

	Database DB = new Database();
	City CTY = new City(DB.getConnection());
	MsgTool MSG = new MsgTool(session);

	String reqEditor = EnvTool.getStr(request, "reqEditor", EnvTool.getStr(session, DETAILS_REQ_EDITOR, ""));
	int ExCty = EnvTool.getInt(request, "excity", -1);

	try {

		City.Data ctyData = CTY.new Data();

		session.setAttribute(DETAILS_REQ_EDITOR, reqEditor); // persistence

		// Prepare to return to a previous city

		String ExpGeoRef = "";

		if (ExCty >= 0) {

			ctyData = CTY.Read(ExCty);
			ExpGeoRef = ctyData.getGeoRef();
		}
%>
		<div class="DS-card-body">
			<div class="mdc-layout-grid__inner">
				<div class="<%= MdcTool.Layout.Cell(6, 4, 4) %> DS-grid-middle-left">
					<div class="DS-text-title-shadow"><%= PAGE_Title %></div>
				</div>
				<div class="<%= MdcTool.Layout.Cell(6, 4, 4) %> DS-grid-middle-right">
					<div class="DS-text-large">
						<form style="margin: 0px">
							<%= MdcTool.Select.Box(
								"reqEditor",
								MdcTool.Select.Width.FULL,
								"", // "Show City List for",
								"<option " + (reqEditor.equals("") ? "selected" : "") + " value=\"\">All (Not filtered)</option>" + CTY.getEditorsCombo(reqEditor),
								"onChange=\"submit();\""
							) %>
						</form>
					</div>
				</div>
			</div>
		</div>

		<div class="DS-card-body">

		<div id="mainDetailsDiv"></div>
<%
		if (reqEditor.equals("")) {

			// Normal view - ALL items via Ajax
%>
			<script>
				var CouDivToClick = '';
				var RegDivToClick = '';
				var PrvDivToClick = '';
				<% if (!ExpGeoRef.equals("")) { %>
					CouDivToClick = 'TH_COU_<%= ExpGeoRef.substring(0, 3) %>';
					RegDivToClick = 'TH_REG_<%= ExpGeoRef.substring(0, 7).replace(":", "_") %>';
					PrvDivToClick = 'TH_PRV_<%= ExpGeoRef.replace(":", "_").replace(".", "_") %>';
				<% } %>
				getCouList('mainDetailsDiv', CouDivToClick, RegDivToClick, PrvDivToClick);
			</script>
<%
		} else {

			// Limited view - Selected Editor only
%>
			<script>
				getCtyList('mainDetailsDiv', '', '<%= reqEditor %>');
			</script>
<%
		}
%>
		</div>

		<div class="DS-card-foot">
			<%= MdcTool.Button.BackTextIcon("Back", "../manage/") %>
		</div>
<%
	} catch (Exception e) {

		MSG.setAlertText("Internal Error", e.toString());
		RedirectTo = "../manage/";
	}

	DB.destroy();
%>
	</div>
	</div>
	</div>

	<jsp:include page="../_common/footer.jsp">
		<jsp:param name="RedirectTo" value="<%= RedirectTo %>" />
	</jsp:include>

</body>
</html>
