<%@ page
	language="java"
	contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="net.danisoft.dslib.*"
%>
<%!
	private static final String PAGE_Title = "Statistics and Summary";
	private static final String PAGE_Keywords = "";
	private static final String PAGE_Description = "";

	private static final String TMP_TABLE = "CMON_tmpStats";
	private static final String HILITE_TD = "background-color: #ffffdd; font-weight: bold;";
%>
<!DOCTYPE html>
<html>
<head>

	<jsp:include page="../_common/head.jsp">
		<jsp:param name="PAGE_Title" value="<%= PAGE_Title %>"/>
		<jsp:param name="PAGE_Keywords" value="<%= PAGE_Keywords %>"/>
		<jsp:param name="PAGE_Description" value="<%= PAGE_Description %>"/>
	</jsp:include>

	<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>

	<script>

		/**
		 * Get Stats after page load
		 */
		$(document).ready(function() {
			getStats('top20reg', 'DIV_TOP20_BY_REG');
			getStats('top20prv', 'DIV_TOP20_BY_PRV');
			getStats('top20edt', 'DIV_TOP20_BY_EDT');
			getStats('top20are', 'DIV_TOP20_BY_ARE');
			getStats('top20sum', 'DIV_TOP20_BY_SUM');
		});

		/**
		 * Get Top20 by Region
		 */
		function getStats(statsName, destDiv) {
		
			$('#' + destDiv).html('<div class="DS-padding-8px" align="center"><img border="0" src="../images/ajax-loader.gif"><br>Creating...</div>');

			$.ajax({

				type: "POST",
				cache: false,
				url: '_inc_stats_' + statsName + '.jsp',

				success: function(data) {
					$('#' + destDiv).html(data);
				},

				error: function(XMLHttpRequest, textStatus, errorThrown) {
					$('#' + destDiv).html('getStats() ERROR ' + XMLHttpRequest.status + ': ' + XMLHttpRequest.statusText);
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
	MsgTool MSG = new MsgTool(session);
/*
	int i;
	Statement st = null;
	Statement stUpd = null;
	ResultSet rs = null;
*/
	try {

		////////////////////////////////////////////////////////////////////////////////
		//
		// HEADER
		//
%>
		<div class="DS-card-body">
			<div class="mdc-layout-grid__inner">
				<div class="<%= MdcTool.Layout.Cell(8, 6, 3) %> DS-grid-middle-left">
					<div class="DS-text-title-shadow"><%= PAGE_Title %></div>
				</div>
				<div class="<%= MdcTool.Layout.Cell(4, 2, 1) %> DS-grid-middle-right">
					<%= MdcTool.Button.TextIconOutlined(
						"lock",
						"&nbsp;Active Users List",
						null,
						"onClick=\"window.location.href='activeusr.jsp'\"",
						""
					) %>
				</div>
			</div>
		</div>

		<div class="DS-card-body">
		<div class="mdc-layout-grid__inner">

			<div class="<%= MdcTool.Layout.Cell(7, 6, 4) %> DS-text-compact">
				<div class="mdc-layout-grid__inner">
					<div class="<%= MdcTool.Layout.Cell(3, 2, 4) %>">
						<div class="mdc-card <%= MdcTool.Elevation.Light() %>">
							<div class="DS-padding-0px" id="DIV_TOP20_BY_REG"></div>
						</div>
					</div>
					<div class="<%= MdcTool.Layout.Cell(3, 2, 4) %>">
						<div class="mdc-card <%= MdcTool.Elevation.Light() %>">
							<div class="DS-padding-0px" id="DIV_TOP20_BY_PRV"></div>
						</div>
					</div>
					<div class="<%= MdcTool.Layout.Cell(3, 2, 4) %>">
						<div class="mdc-card <%= MdcTool.Elevation.Light() %>">
							<div class="DS-padding-0px" id="DIV_TOP20_BY_EDT"></div>
						</div>
					</div>
					<div class="<%= MdcTool.Layout.Cell(3, 2, 4) %>">
						<div class="mdc-card <%= MdcTool.Elevation.Light() %>">
							<div class="DS-padding-0px" id="DIV_TOP20_BY_ARE"></div>
						</div>
					</div>
				</div>
			</div>
			
			<div class="<%= MdcTool.Layout.Cell(5, 2, 4) %>">
				<div class="mdc-card <%= MdcTool.Elevation.Light() %>">
					<div class="DS-padding-0px" id="DIV_TOP20_BY_SUM"></div>
				</div>
			</div>

		</div>
		</div>
<%
		////////////////////////////////////////////////////////////////////////////////
		//
		// FOOTER
		//
%>
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
		<jsp:param name="RedirectTo" value="<%= RedirectTo %>"/>
	</jsp:include>

</body>
</html>
