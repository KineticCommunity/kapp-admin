<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <!-- Set currentConsole (AdminConsole) and currentKapp (Kapp) for later use in building the page. -->
    <c:set var="currentConsole" value="${AdminHelper.getCurrentAdminConsole(param.page)}" scope="request"/>
    <c:choose>
        <c:when test="${empty space.getKapp(param.kapp) && not empty space.kapps}">
            <c:set var="currentKapp" value="${space.kapps[0]}" scope="request"/>
        </c:when>
        <c:otherwise>
            <c:set var="currentKapp" value="${space.getKapp(param.kapp)}" scope="request"/>
        </c:otherwise>
    </c:choose>
    
    <!-- Sets title and imports js and css specific to this console. -->
    <bundle:variable name="head">
        <title>Admin Console<c:if test="${text.isNotEmpty(currentConsole.name)}"> | ${currentConsole.name}</c:if></title>
        <c:import url="${bundle.path}/partials/${currentConsole.slug}/head.jsp" charEncoding="UTF-8"/>
    </bundle:variable>
    
    <!-- Includes the top tabbed navigation. Remove if not needed. -->
    <bundle:variable name="navbar">
        <c:import url="${bundle.path}/partials/${currentConsole.slug}/navbar.jsp" charEncoding="UTF-8"/>
    </bundle:variable>
    
    <!-- Includes the sidebar navigation (Kapp navigation by default). Remove if not needed. -->
    <bundle:variable name="sidebar">
        <c:import url="${bundle.path}/partials/sidebarKapps.jsp" charEncoding="UTF-8"/>
    </bundle:variable>
    
    <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
    
    <div class="page-header">
        <h3>${currentKapp.name}</h3>
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

    <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
    
    <!-- Includes right sidebar. Remove if not needed. -->
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