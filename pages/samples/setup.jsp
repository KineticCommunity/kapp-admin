<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <bundle:variable name="head">
        <title>Samples :: ${text.escape(space.name)}</title>
        <c:import url="${bundle.path}/partials/samples/head.jsp" charEncoding="UTF-8"/>
    </bundle:variable>
    
    <bundle:variable name="navbar">
        <c:import url="${bundle.path}/partials/samples/navbar.jsp" charEncoding="UTF-8"/>
    </bundle:variable>
    
    <bundle:variable name="sidebar">
        <c:import url="${bundle.path}/partials/samples/sidebarBuild.jsp" charEncoding="UTF-8"/>
    </bundle:variable>
    
    <bundle:variable name="content">
        <div class="page-header">
            <h3>Setup</h3>
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
    </bundle:variable>
    
    <bundle:variable name="aside">
        <h3>TITLE</h3>
        <p>
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor 
            incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud 
            exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute 
            irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla 
            pariatur.
        </p>
    </bundle:variable>
</bundle:layout>