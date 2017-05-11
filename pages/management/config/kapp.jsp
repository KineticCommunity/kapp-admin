<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../../bundle/initialization.jspf" %>

<c:set var="console" value="${form}" scope="request"/>
<c:set var="currentKapp" value="${space.getKapp(param.kapp)}" scope="request"/>
<c:set var="isKappOwner" value="${identity.spaceAdmin || TeamsHelper.isKappOwner(identity.user, currentKapp)}" scope="request"/>

<c:choose>
    <c:when test="${empty currentKapp}">
        <c:set var="error" value="${i18n.translate('No kapps with the slug KAPPSLUG exist.')
            .replace('KAPPSLUG', '<b>KAPPSLUG</b>').replace('KAPPSLUG', text.defaultIfBlank(param.kapp, ''))}" />
    </c:when>
    <c:when test="${not isKappOwner}">
        <c:set var="error" value="${i18n.translate('You do not have permission to configure the KAPPNAME kapp.')
            .replace('KAPPNAME', '<b>KAPPNAME</b>').replace('KAPPNAME', currentKapp.name)}" />
    </c:when>
</c:choose>
    
<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <%-- Sets title and imports js and css specific to this console. --%>
    <bundle:variable name="head">
        <c:import url="${bundle.path}/partials/management/head.jsp" charEncoding="UTF-8"/>
        <bundle:scriptpack>
            <bundle:script src="${bundle.location}/js/management/categories.js"/>
        </bundle:scriptpack>
    </bundle:variable>

    
    <%-- BREADCRUMBS START HERE. Remove if not needed. -------------------------------------------%>
    <bundle:variable name="breadcrumb">
        <li><a href="${bundle.kappLocation}/${console.slug}">${console.name}</a></li>
        <c:choose>
            <c:when test="${not empty currentKapp}">
                <li><a href="${bundle.kappLocation}/${console.slug}?page=management/kapp&kapp=${currentKapp.slug}">${text.escape(currentKapp.name)}</a></li>
                <li class="active">Configuration</li>
            </c:when>
            <c:otherwise>
                <li class="active">Kapp Not Found</li>
            </c:otherwise>
        </c:choose>
    </bundle:variable>
    <%-- BREADCRUMBS END HERE. -------------------------------------------------------------------%>

    <c:choose>
        <c:when test="${empty error}">
        
            <%-- PAGE CONTENT STARTS HERE --------------------------------------------------------%>
    
            <div class="page-header">
                <h2>
                    <span>${text.escape(currentKapp.name)}</span>
                    <small>Kapp Configuration</small>
                </h2>
            </div>
            
            <div class="kapp-configuration-container">
                <ul class="nav nav-tabs h4 stacked-xs" role="tablist" id="kapp-configuration-tabs">
                    <li role="presentation" class="active"><a href="#display" aria-controls="display" role="tab" data-toggle="tab">${i18n.translate('Display Options')}</a></li>
                    <li role="presentation"><a href="#workflow" aria-controls="workflow" role="tab" data-toggle="tab">${i18n.translate('Workflow Options')}</a></li>
                    <li role="presentation"><a href="#categories" aria-controls="categories" role="tab" data-toggle="tab">${i18n.translate('Categories')}</a></li>
                </ul>
                
                <div class="tab-content">
                    
                    <%-- DISPLAY OPTIONS ----------------------------------------------------------------%>
                    <div role="tabpanel" class="tab-pane active" id="display" 
                         data-save-container data-source="/kapps/${currentKapp.slug}" data-source-name="kapp"
                         data-config-partial="/config/kapp/display&kapp=${currentKapp.slug}">
                         
                        <c:import url="${bundle.path}/partials/management/config/kapp/display.jsp" charEncoding="UTF-8" />
                                        
                    </div>
                    
                    <%-- WORKFLOW OPTIONS ----------------------------------------------------------------%>
                    <div role="tabpanel" class="tab-pane" id="workflow" 
                         data-save-container data-source="/kapps/${currentKapp.slug}" data-source-name="kapp"
                         data-config-partial="/config/kapp/workflow&kapp=${currentKapp.slug}">
                         
                        <c:import url="${bundle.path}/partials/management/config/kapp/workflow.jsp" charEncoding="UTF-8" />
                                        
                    </div>
                
                    <%-- CATEGORIES ----------------------------------------------------------------------%>
                    <div role="tabpanel" class="tab-pane" id="categories" 
                         data-save-container data-source="/kapps/${currentKapp.slug}" data-source-name="kapp">
                         
                        <c:import url="${bundle.path}/partials/management/config/kapp/categories.jsp" charEncoding="UTF-8" />
                                        
                    </div>
                
                </div>
            </div>
            
            <%-- PAGE CONTENT ENDS HERE ---------------------------------------------------------%>
    
            <%-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -----------------------%>
            <bundle:variable name="aside">
                <h3>Kapp Management</h3>
                <h5>${currentKapp.name}</h5>
                <hr />
                <p>Here you can update different properties of the kapp including display options, workflow options, and categories.</p>
                <p>The system was designed to be hierarchical so that properties configured here at the kapp level will override properties set at the space level.</p>
                <p>If any properties are not configured here, the properties set at the space level will be used.</p>
                <p>Furthermore, if the properties are set at the form level, those will override the properties set here.</p>
                <c:if test="${identity.spaceAdmin}">
                    <hr />
                    <h6>Advanced Management</h6>
                    <p>
                        Visit the <a href="${bundle.spaceLocation}/app/#/${currentKapp.slug}/activity/overview" target="_blank">Kinetic Request</a> 
                        Management Console for advanced configuration options.
                    </p>
                </c:if>
            </bundle:variable>
            <%-- RIGHT SIDEBAR CONTENT ENDS HERE. -----------------------------------------------%>
            
        </c:when>
        <c:otherwise>
            <c:import url="${bundle.path}/partials/error.jsp" charEncoding="UTF-8">
                <c:param name="message" value="${error}"/>
            </c:import>
        </c:otherwise>
    </c:choose>
    
</bundle:layout>