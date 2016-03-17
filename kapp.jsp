<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="bundle/initialization.jspf" %>
<%@include file="bundle/router.jspf" %>
<c:set var="bundleCategories" value="${CategoryHelper.getCategories(kapp)}"/>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <bundle:variable name="head">
        <title>Kinetic Data ${text.escape(kapp.name)}</title>
    </bundle:variable>
        
    <bundle:variable name="sidebar">
        <c:import url="${bundle.path}/partials/sidebars/topnav1.jsp" charEncoding="UTF-8"/>
    </bundle:variable>
        
    <div class="row">
        <div class="col-xs-9 content-main">
            <div class="page-header">
                <h3>Title</h3>
            </div>

            <div class="row">
                <div class="col-xs-12">
                    <div class="content-tabs">
                        <ul class="nav nav-pills sub-nav">
                            <li class="active">
                                <a href="javascript:void(0);">Tab 1</a>
                            </li>
                            <li>
                                <a href="javascript:void(0);">Tab 2</a>
                            </li>
                            <li>
                                <a href="javascript:void(0);">Tab 3</a>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xs-3 sidebar pull-right">
            <h3>TITLE</h3>
            <p>
                Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor 
                incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud 
                exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute 
                irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla 
                pariatur.
            </p>
        </div>
    </div>
</bundle:layout>