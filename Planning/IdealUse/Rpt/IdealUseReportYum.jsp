
<jsp:include page = '/Include/ValidateSessionYum.jsp'/>

<%--
##########################################################################################################
# Nombre Archivo  : IdealUseReportYum.jsp
# Compania        : Yum Brands Intl
# Autor           : Sergio Cuellar
# Objetivo        : Obtener historico de usos ideales de ciertos productos de acuerdo al pron de transacciones
# Fecha Creacion  : 02/febrero/2011
# Inc/requires    :
# Modificaciones  :
##########################################################################################################
--%>

<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="generals.*" %>
<%@ page import=" java.io.*" %>

<%@ include file="/Include/CommonLibYum.jsp" %>
<%@ include file="../Proc/IdealUseLibYum.jsp" %>

<%! AbcUtils moAbcUtils = new AbcUtils();

    String msYear;
    String msPeriod;
    String msWeek;
    String msWeekId;
    String msDay;
    String msReport;
    String msMessage;
    boolean reportOk;
    String msDataset;
%>

<%
    try
    {
        msYear    		= request.getParameter("hidSelectedYear");
        msPeriod  		= request.getParameter("hidSelectedPeriod");
        msWeek    		= request.getParameter("hidSelectedWeek");
        msDay     		= request.getParameter("hidSelectedDay");
        msReport  		= request.getParameter("hidReportType");
        msDataset = "new Array()";


		msMessage = "";
		reportOk  = false;

		System.out.println("msDay = "+msDay+" msWeek = "+msWeek+" msPeriod = "+msPeriod+" msResport = "+msReport+" msYear= "+msYear);

		if(!msDay.equals("0"))
		{
			msWeekId = getWeekId(msYear, msPeriod, msWeek);
		}

		if(msReport.equals("3"))//Se tiene que escoger un dia
		{
		        reportOk  = true;
                        msDataset = getDataset(msWeek, msYear, msPeriod, msWeekId, msDay);
		}
		else
		{
			if(!msReport.equals("3"))
				msMessage = "Seleccione algun dia del calendario Yum.";
			else
				msMessage = "Para obtener el reporte, seleccione un dia del calendario Yum";
		}
    }
    catch(Exception e)
    {
		System.out.println("Exception .. " + e);
    }
%>

<html>
	<head>
		<%@ include file="/Include/CalendarLibYum.jsp" %>
		<script language="javascript" src="/Scripts/HtmlUtilsYum.js"></script>
                <link rel="stylesheet" href="/CSS/WaitMessageYum.css" type="text/css">
		<script>
			var reportOk = <%= reportOk %>;

			function submitFrame(frameName)
			{
                document.mainform.target = frameName;

				if(frameName=='preview')
                	document.mainform.hidTarget.value = "Preview";

				if(frameName=='printer')
                	document.mainform.hidTarget.value = "Printer";

                document.mainform.submit();
			}
			function submitFrames()
			{
				setTimeout("submitFrame('printer')", 1000);
				//Despues de 2 seg se carga el segundo frame
				setTimeout("submitFrame('preview')", 3000);
			}

			function doAction()
			{

				if(reportOk == true)
				{
					submitFrames();
				}
				else
				{	
					document.mainform.action = '/MessageYum.jsp';
					addHidden(document.mainform, 'hidTitle', 'Uso Ideal Diario');
					addHidden(document.mainform, 'hidSplit', 'true');
					submitFrame('preview');
				}
			}

                        var gaDataset = <%= msDataset %>;
		

		</script>
	</head>
	<body onLoad="doAction()" style="margin-left: 0px; margin-right: 0px">
        <table width="100%" cellpadding="0" cellspacing="0">
        <tr>
            <td width="100%">
                <iframe name="preview" width="100%" height="530" frameborder="0"></iframe>
            </td>
        </tr>
        <tr>
            <td width="100%">
                <iframe name="printer" width="100%" height="5" frameborder="0"></iframe>
            </td>
        </tr>
        </table>                      
        <form name="mainform" action="IdealUseReportFrm.jsp">
            <input type="hidden" name="year" value="<%= msYear %>">
            <input type="hidden" name="period" value="<%= msPeriod %>">
            <input type="hidden" name="weekId" value="<%= msWeekId %>">
            <input type="hidden" name="day" value="<%= msDay %>">
            <input type="hidden" name="week" value="<%= msWeek %>">
            <input type="hidden" name="hidTarget">
            <input type="hidden" name="hidMessage" value="<%= msMessage %>">
        </form>
	</body>
</html>

