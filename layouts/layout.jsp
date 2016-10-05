<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../bundle/initialization.jspf" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1.0, maximum-scale=1.0">
        <link rel="apple-touch-icon" sizes="76x76" href="${bundle.location}/images/apple-touch-icon.png">
        <link rel="icon" type="image/png" href="${bundle.location}/images/android-chrome-96x96.png" sizes="96x96">
        <link rel="icon" type="image/png" href="${bundle.location}/images/favicon-16x16.png" sizes="16x16">
        <link rel="icon" type="image/png" href="${bundle.location}/images/favicon-32x32.png" sizes="32x32">
        <link rel="icon" type="image/png" href="${bundle.location}/images/favicon-96x96.png" sizes="96x96">
        <link rel="shortcut icon" href="${bundle.location}/images/favicon.ico" type="image/x-icon"/>
        <title>Admin Console<c:if test="${not empty form}"> | ${form.name}</c:if></title>
        <app:headContent/>
        <link href="${bundle.location}/libraries/font-awesome/css/font-awesome.css" rel="stylesheet" type="text/css"/>
        <bundle:stylepack>
            <bundle:style src="${bundle.location}/libraries/bootstrap/css/bootstrap.css"/>
            <bundle:style src="${bundle.location}/libraries/datatables/datatables.css"/>
            <bundle:style src="${bundle.location}/libraries/jquery.fileupload/jquery.fileupload.css"/>
            <bundle:style src="${bundle.location}/libraries/notifie/jquery.notifie.css"/>
            <bundle:style src="${bundle.location}/css/master.css"/>
        </bundle:stylepack>
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
            <bundle:script src="${bundle.location}/libraries/typeahead/typeahead.min.js"/>
            <bundle:script src="${bundle.location}/js/admin.js"/>
            <bundle:script src="${bundle.location}/js/review.js"/>
        </bundle:scriptpack>
        <%-- Moment-with-locales.js is incompatible with the bundle:scriptpack minification process. --%>
        <bundle:scriptpack minify="false">
            <bundle:script src="${bundle.location}/libraries/moment/moment-with-locales.min.js"/>
        </bundle:scriptpack>
        <bundle:yield name="head"/>
    </head>
    <body>
        <div class="view-port">
            <c:set var="aside"><bundle:yield name="aside"/></c:set>
<%--             <c:import url="${space.bundleBase}/${space.bundlePath}/partials/header.jsp" charEncoding="UTF-8"/> --%>
            <c:import url="${bundle.path}/partials/header.jsp" charEncoding="UTF-8"/>
            <c:import url="${bundle.path}/partials/subheader.jsp" charEncoding="UTF-8"/>
            <div class="container main-inner">
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
            </div>
<%--             <c:import url="${space.bundleBase}/${space.bundlePath}/partials/footer.jsp" charEncoding="UTF-8"/> --%>
            <c:import url="${bundle.path}/partials/footer.jsp" charEncoding="UTF-8"/>
        </div>
    </body>
</html>