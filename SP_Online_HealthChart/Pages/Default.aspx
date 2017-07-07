<%-- The following 4 lines are ASP.NET directives needed when using SharePoint components --%>

<%@ Page Inherits="Microsoft.SharePoint.WebPartPages.WebPartPage, Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" MasterPageFile="~masterurl/default.master" Language="C#" %>

<%@ Register TagPrefix="Utilities" Namespace="Microsoft.SharePoint.Utilities" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>

<%-- The markup and script in the following Content element will be placed in the <head> of the page --%>
<asp:Content ContentPlaceHolderID="PlaceHolderAdditionalPageHead" runat="server">
    
   <SharePoint:ScriptLink name="sp.js" runat="server" OnDemand="true" LoadAfterUI="true" Localizable="false" />
   
  
      <style type="text/css">
        #ProjectStatus {
            border: 1px solid gray;
            margin-bottom: 15px;
            margin-right: -18px;
        }

        #ProjectStatusPie {
            border: 1px solid gray;
        }

        #LateTask {
            border: 1px solid gray;
            margin-left: 560px;
            margin-top: -402px;
        }
    </style>

    <script type="text/javascript" src="../Scripts/jquery-1.9.1.min.js"></script>
    <script type="text/javascript" src="/_layouts/15/MicrosoftAjax.js"></script>
    <script type="text/javascript" src="/_layouts/15/sp.runtime.js"></script>
    <script type="text/javascript" src="/_layouts/15/sp.js"></script>  
  

    <!-- Add your JavaScript to the following file -->
    <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/linq.js/2.2.0.2/linq.min.js"></script>
    <script type="text/javascript" src="https://code.jquery.com/jquery-1.9.1.min.js"></script>
    <script type="text/javascript" src="https://kendo.cdn.telerik.com/2015.3.1111/js/kendo.all.min.js"></script>

    <!-- CSS Reference  -->
    <link rel="stylesheet" type="text/css" href="https://kendo.cdn.telerik.com/2015.3.1111/styles/kendo.common.min.css" />
    <link rel="stylesheet" type="text/css" href="https://kendo.cdn.telerik.com/2015.3.1111/styles/kendo.rtl.min.css" />
    <link rel="stylesheet" type="text/css" href="https://kendo.cdn.telerik.com/2015.3.1111/styles/kendo.silver.min.css" />
    <link rel="stylesheet" type="text/css" href="https://kendo.cdn.telerik.com/2017.2.504/styles/kendo.uniform.min.css" />
    <link rel="stylesheet" type="text/css" href="https://kendo.cdn.telerik.com/2015.3.1111/styles/kendo.mobile.all.min.css" />
    <script type="text/javascript">
        // Set the style of the client web part page to be consistent with the host web.
        (function ()
           {
            'use strict';

            var hostUrl = '';
            var link = document.createElement('link');
            link.setAttribute('rel', 'stylesheet');
            if (document.URL.indexOf('?') != -1) {
                var params = document.URL.split('?')[1].split('&');
                for (var i = 0; i < params.length; i++) {
                    var p = decodeURIComponent(params[i]);
                    if (/^SPHostUrl=/i.test(p)) {
                        hostUrl = p.split('=')[1];
                        link.setAttribute('href', hostUrl + '/_layouts/15/defaultcss.ashx');
                        break;
                    }
                }
            }
            if (hostUrl == '') {
                link.setAttribute('href', '/_layouts/15/1033/styles/themable/corev15.css');
            }
            document.head.appendChild(link);
        })();
    </script>



     <script type="text/javascript">
        var hostweburl;
        var appweburl;
        // Load the required SharePoint libraries
        $(document).ready(function () {
            //Get the URI decoded URLs.
            hostweburl = decodeURIComponent(getQueryStringParameter("SPHostUrl") );
            appweburl =decodeURIComponent( getQueryStringParameter("SPAppWebUrl"));
            alert(hostweburl);
            alert(appweburl);
           
        });
     
        
        
        function getQueryStringParameter(paramToRetrieve) {
            var params =
                document.URL.split("?")[1].split("&");
            var strParams = "";
            for (var i = 0; i < params.length; i = i + 1) {
                var singleParam = params[i].split("=");
                if (singleParam[0] == paramToRetrieve)
                    return singleParam[1];
            }
        }
    </script>
    
    
    <script type="text/javascript">

        function getBarChartValue(data) {

            var chartData = [];

            if (data.d.results.length > 0) {

                var myresults = data.d.results;
                //console.log(JSON.stringify(data.d.results));
                for (var i = 0; i < myresults.length; i++) {
                    chartData.push({
                        MainTasks: myresults[i].MainTasks,
                        value: 1,
                        ScheduleStatus: myresults[i].ScheduleStatus
                    });
                }
            }
            //Sum Group by      
            var aggregatedObject = Enumerable.From(chartData)
                .GroupBy("$.MainTasks", null,
                function (key, g) {
                    return {
                        MainTasks: key,
                        value: g.Sum("$.value"),
                        Incomplete: g.Where("$.ScheduleStatus == 'Incomplete'").Sum("$.value"),
                        Completed: g.Where("$.ScheduleStatus == 'Completed'").Sum("$.value"),
                        OnSchedule: g.Where("$.ScheduleStatus == 'On Schedule'").Sum("$.value"),
                        Future: g.Where("$.ScheduleStatus == 'Future'").Sum("$.value"),
                        BehindSchedule: g.Where("$.ScheduleStatus == 'Behind Schedule'").Sum("$.value"),
                        SignificantlyBehindSchedule: g.Where("$.ScheduleStatus == 'Significantly Behind Schedule'").Sum("$.value")
                    }
                })
                .ToArray();

            return aggregatedObject;
        }

        function getData(_url) {
            var deferred = $.ajax({
                url:appweburl + "/_api/SP.AppContextSite(@target)/web/lists/getbytitle('Tasks')/items?&@target='" + hostweburl + "'",
           
                type: "GET",
                headers: {
                    "accept": "application/json;odata=verbose",
                },
                success: function (data) {
                    return data;
                },
                error: function (err) {
                    console.log(err);
                }
            });

            return deferred.promise()

        };

        function createChart() {
            var hostweburl = decodeURIComponent(getQueryStringParameter("SPHostUrl"));
            var appweburl = decodeURIComponent(getQueryStringParameter("SPAppWebUrl"));
            //alert(hostweburl);
            //alert(appweburl);
            // var appweburl = decodeURIComponent(getQueryStringParameter("SPAppWebUrl"));
            //var _url = appweburl + "/_api/SP.AppContextSite(@target)/web/lists/getbytitle('Tasks')/items";
            var _url = appweburl + "/_api/SP.AppContextSite(@target)/web/lists/getbytitle('Tasks')/items?&@target='" + hostweburl;// + "';
            //('Tasks')/items?&@target
            getData(_url).done(
                function (response) {
                    $("#ProjectStatus").kendoChart({
                        dataSource: getBarChartValue(response),
                        title: {
                            text: "Project Health Check"
                        },
                        legend: {
                            position: "top"
                        },
                        seriesDefaults: {
                            type: "bar",
                            stack: true
                        },
                        series: [{
                            field: "SignificantlyBehindSchedule",
                            stack: "Series1",
                            name: "Significantly Behind Schedule",
                            color: "#ed7d31"
                        },
                        {
                            field: "Completed",
                            stack: "Series1",
                            name: "Completed",
                            color: "#4472c4"
                        },
                        {
                            field: "Incomplete",
                            stack: "Series1",
                            name: "Incomplete",
                            color: "#c00000"
                        },
                        {
                            field: "OnSchedule",
                            stack: "Series1",
                            name: "On Schedule",
                            color: "#92d050"
                        },
                        {
                            field: "BehindSchedule",
                            stack: "Series1",
                            name: "Behind Schedule",
                            color: "#ffbf00"
                        },
                        {
                            field: "Future",
                            stack: "Series1",
                            name: "Future",
                            color: "#96d0ca"
                        }],
                        categoryAxis: {
                            field: "MainTasks",
                        },
                        tooltip: {
                            visible: true,
                            format: "N0"
                        }
                    });

                });
        }

        $(document).ready(createChart);
        $(document).bind("kendo:skinChange", createChart);
    </script>

</asp:Content>

<%-- The markup in the following Content element will be placed in the TitleArea of the page --%>
<asp:Content ContentPlaceHolderID="PlaceHolderPageTitleInTitleArea" runat="server">
    Page Title
</asp:Content>

<%-- The markup and script in the following Content element will be placed in the <body> of the page --%>
<asp:Content ContentPlaceHolderID="PlaceHolderMain" runat="server">
    <ul id="ticker"></ul>
     <div id="internal"></div>
    <div id="example">
    <div class="demo-section k-content wide">
        <div id="ProjectStatus"></div>
    </div>
<div>
        <div id="ProjectStatusPie" style="width:50%"></div>
        <div id="LateTask" style="width:50%"></div>
</div>
</div>
    <div>
        <p id="message">
            <!-- The following content will be replaced with the user name when you run the app - see App.js -->
            initializing...
        </p>
    </div>

</asp:Content>
