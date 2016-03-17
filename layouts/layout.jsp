<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../bundle/initialization.jspf" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1.0, maximum-scale=1.0">
        <link rel="shortcut icon" href="${bundle.location}/images/favicon.ico" type="image/x-icon"/>
        <link rel="apple-touch-icon" sizes="76x76" href="${bundle.location}/images/apple-touch-icon.png">
        <link rel="icon" type="image/png" href="${bundle.location}/images/android-chrome-96x96.png" sizes="96x96">
        <link rel="icon" type="image/png" href="${bundle.location}/images/favicon-16x16.png" sizes="16x16">
        <link rel="icon" type="image/png" href="${bundle.location}/images/favicon-32x32.png" sizes="32x32">
        <link rel="icon" type="image/png" href="${bundle.location}/images/favicon-96x96.png" sizes="96x96">
        <app:headContent/>
        <bundle:stylepack>
            <bundle:style src="${bundle.location}/libraries/bootstrap/css/bootstrap.css"/>
            <bundle:style src="${bundle.location}/libraries/font-awesome/css/font-awesome.min.css"/>
            <bundle:style src="${bundle.location}/css/master.css"/>
        </bundle:stylepack>
        <link href="${bundle.location}/libraries/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css"/>
        <bundle:scriptpack>
            <bundle:script src="${bundle.location}/libraries/jquery-datatables/jquery.dataTables.js" />
            <bundle:script src="${bundle.location}/js/review.js" />
        </bundle:scriptpack>
        <bundle:yield name="head"/>
    </head>
    <body>
        <div class="task-wrapper">
            <c:import url="${bundle.path}/partials/header.jsp" charEncoding="UTF-8"/>
            
            <bundle:yield name="navbar"/>
            
            <section class="content">
                <div class="container-fluid main-inner">
                    <div class="row">
                        <c:set var="sidebar"><bundle:yield name="sidebar"/></c:set>
                        <c:set var="aside"><bundle:yield name="aside"/></c:set>
                        <c:choose>
                            <c:when test="${Text.isBlank(sidebar) && Text.isBlank(aside)}">
                                <div class="col-xs-12 tab-content">
                                    <div class="row">
                                        <div class="col-xs-12 content-main">
                                            <bundle:yield name="content"/>
                                        </div>
                                    </div>
                                </div>
                            </c:when>
                            <c:when test="${Text.isBlank(sidebar)}">
                                <div class="col-xs-12 tab-content">
                                    <div class="row">
                                        <div class="col-xs-9 content-main">
                                            <bundle:yield name="content"/>
                                        </div>
                                        <div class="col-xs-3 sidebar pull-right">
                                            <bundle:yield name="aside"/>
                                        </div>
                                    </div>
                                </div>
                            </c:when>
                            <c:when test="${Text.isBlank(aside)}">
                                <div class="col-xs-2 sidebar">
                                    <bundle:yield name="sidebar"/>
                                </div>
                                <div class="col-xs-10 tab-content">
                                    <div class="row">
                                        <div class="col-xs-12 content-main">
                                            <bundle:yield name="content"/>
                                        </div>
                                    </div>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="col-xs-2 sidebar">
                                    <bundle:yield name="sidebar"/>
                                </div>
                                <div class="col-xs-10 tab-content">
                                    <div class="row">
                                        <div class="col-xs-9 content-main">
                                            <bundle:yield name="content"/>
                                        </div>
                                        <div class="col-xs-3 sidebar pull-right">
                                            <bundle:yield name="aside"/>
                                        </div>
                                    </div>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </section>
                        
            <c:import url="${bundle.path}/partials/footer.jsp" charEncoding="UTF-8"/>
        </div>
    </body>
</html>
