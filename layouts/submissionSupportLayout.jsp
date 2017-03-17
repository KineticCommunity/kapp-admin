<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../bundle/initialization.jspf" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1.0, maximum-scale=1.0">
        <!-- Chrome Toolbar Color -->
        <meta content='#ff7700' name='theme-color'>
        <meta content='yes' name='mobile-web-app-capable'>
        <meta content='Kinetic Data, Inc.' name='application-name'>
        <link href="${bundle.location}/images/touch/homescreen192.png" rel="icon" type="image/png" sizes="192x192" />
        <meta content='no' name='apple-mobile-web-app-capable'>
        <meta content='black' name='apple-mobile-web-app-status-bar-style'>
        <meta content='Kinetic Data, Inc.' name='apple-mobile-web-app-title'>
        <!-- Touch Icons -->
        <link href="${bundle.location}/images/touch/homescreen72-fav.png" rel="shortcut icon" type="image/png" />
        <link href="${bundle.location}/images/touch/homescreen48.png" rel="apple-touch-icon" type="image/png" />
        <link href="${bundle.location}/images/touch/homescreen72.png" rel="apple-touch-icon" type="image/png" sizes="72x72" />
        <link href="${bundle.location}/images/touch/homescreen96.png" rel="apple-touch-icon" type="image/png" sizes="96x96" />
        <link href="${bundle.location}/images/touch/homescreen144.png" rel="apple-touch-icon" type="image/png" sizes="144x144" />
        <link href="${bundle.location}/images/touch/homescreen192.png" rel="apple-touch-icon" type="image/png" sizes="192x192" />
        <link href="${bundle.location}/images/touch/safari-pinned-tab.svg" rel="mask-icon" type="image/svg" color="#ff7700" />
        <!-- Windows Tile Image -->
        <meta content='${bundle.location}/images/touch/homescreen144.png' name='msapplication-TileImage'>
        <meta content='#ff7700' name='msapplication-TileColor'>
        <meta content='no' name='msapplication-tap-highlight'>
        <link rel="shortcut icon" href="${bundle.location}/images/favicon.ico" type="image/x-icon"/>
        <app:headContent/>
        <link href="${bundle.location}/libraries/font-awesome/css/font-awesome.css" rel="stylesheet" type="text/css"/>
        <bundle:stylepack>
            <bundle:style src="${bundle.location}/libraries/bootstrap/css/bootstrap.css"/>
            <bundle:style src="${bundle.location}/libraries/datatables/datatables.css"/>
            <bundle:style src="${bundle.location}/libraries/jquery.fileupload/jquery.fileupload.css"/>
            <bundle:style src="${bundle.location}/libraries/notifie/jquery.notifie.css"/>
            <bundle:style src="${bundle.location}/libraries/kd-typeahead/kd-typeahead.css"/>
            <bundle:style src="${bundle.location}/css/master.css"/>
        </bundle:stylepack>
        <%-- Set User Locale into bundle object. --%>
        <script>bundle.config.userLocale = '${locale}';</script>
        <bundle:scriptpack>
            <bundle:script src="${bundle.location}/libraries/jquery/jquery.min.js" />
            <bundle:script src="${bundle.location}/libraries/underscore/underscore.js"/>
            <bundle:script src="${bundle.location}/libraries/datatables/datatables.js"/>
            <bundle:script src="${bundle.location}/libraries/jquery-ui/jquery-ui.js"/>
            <bundle:script src="${bundle.location}/libraries/jquery.fileupload/jquery.fileupload.js"/>
            <bundle:script src="${bundle.location}/libraries/bootstrap/js/bootstrap.js"/>
            <bundle:script src="${bundle.location}/libraries/kd-search/search.js"/>
            <bundle:script src="${bundle.location}/libraries/jquery-csv/jquery.csv.js"/>
            <bundle:script src="${bundle.location}/libraries/notifie/jquery.notifie.js"/>
            <bundle:script src="${bundle.location}/libraries/typeahead/typeahead.js"/>
            <bundle:script src="${bundle.location}/libraries/kd-typeahead/kd-typeahead.js"/>
            <bundle:script src="${bundle.location}/js/admin.js"/>
            <bundle:script src="${bundle.location}/js/review.js"/>
        </bundle:scriptpack>
        <%-- Moment-with-locales.js is incompatible with the bundle:scriptpack minification process. --%>
        <bundle:scriptpack minify="false">
            <bundle:script src="${bundle.location}/libraries/moment/moment-with-locales.min.js"/>
        </bundle:scriptpack>
        <c:set var="pageTitle"><bundle:yield name="pageTitle"/></c:set>
        <title>
           ${text.join([not empty pageTitle ? pageTitle : text.defaultIfBlank(form.name, kapp.name), AdminHelper.companyName], ' - ')}
           ${space.hasAttribute('Page Title Brand') ? text.join([' | ', space.getAttributeValue('Page Title Brand')]) : ''}
        </title>
        <bundle:yield name="head"/>
    </head>
    <body>
        <div class="view-port">
            <c:set var="aside"><bundle:yield name="aside"/></c:set>
            <c:import url="${headerPath}/partials/header.jsp" charEncoding="UTF-8"/>
                <div class="row">
                    <div class="col-xs-12 tab-content">
                        <div class="row">
                            <c:choose>
                                <c:when test="${not empty aside}">
                                    <div class="col-sm-9 content-main">
                                        <bundle:yield/>
                                    </div>
                                    <div class="col-sm-3 hidden-xs aside pull-right">
                                        <bundle:yield name="aside"/>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="col-xs-12 content-main">
                                        <bundle:yield/>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            <c:import url="${footerPath}/partials/footer.jsp" charEncoding="UTF-8"/>
        </div>
    </body>
</html>
