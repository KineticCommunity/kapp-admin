<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../../bundle/initialization.jspf" %>

<c:set var="console" value="${form}" scope="request"/>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <%-- Sets title and imports js and css specific to this console. --%>
    <bundle:variable name="head">
        <c:import url="${bundle.path}/partials/management/head.jsp" charEncoding="UTF-8"/>
    </bundle:variable>

    
    <%-- BREADCRUMBS START HERE. Remove if not needed. ------------------------------------------%>
    <bundle:variable name="breadcrumb">
        <li><a href="${bundle.kappLocation}/${console.slug}">${console.name}</a></li>
        <li class="active">Space Configuration</li>
    </bundle:variable>
    <%-- BREADCRUMBS END HERE. ------------------------------------------------------------------%>

    <%-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------%>
    
    <div class="page-header">
        <h2>
            <span>${text.escape(space.name)}</span>
            <small>Space Configuration</small>
        </h2>
    </div>
    
    <div class="space-configuration-container">
        <ul class="nav nav-tabs h4 stacked-xs" role="tablist" id="space-configuration-tabs">
            <li role="presentation" class="active"><a href="#display" aria-controls="display" role="tab" data-toggle="tab">${i18n.translate('Display Options')}</a></li>
            <li role="presentation"><a href="#workflow" aria-controls="workflow" role="tab" data-toggle="tab">${i18n.translate('Workflow Options')}</a></li>
        </ul>
        
        <div class="tab-content">
        
            <%-- DISPLAY OPTIONS ----------------------------------------------------------------%>
            <div role="tabpanel" class="tab-pane active" id="display" 
                 data-save-container data-source="/space" data-source-name="space"
                 data-config-partial="/config/space/display">
                 
                <c:import url="${bundle.path}/partials/management/config/space/display.jsp" charEncoding="UTF-8" />
                                
            </div>
            
            <%-- WORKFLOW OPTIONS ----------------------------------------------------------------%>
            <div role="tabpanel" class="tab-pane" id="workflow" 
                 data-save-container data-source="/space" data-source-name="space"
                 data-config-partial="/config/space/workflow">
                 
                <c:import url="${bundle.path}/partials/management/config/space/workflow.jsp" charEncoding="UTF-8" />
                                
            </div>
        
        </div>
    </div>
    
    <%-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -------------------------------%>
    <bundle:variable name="aside">
        <h3>Space Management</h3>
        <h5>${space.name}</h5>
        <hr />
        <p>Here you can update different properties of the space including display options and workflow options.</p>
        <p>The system was designed to be hierarchical so that properties set here at the space level will be the defaults used if they are not set at the kapp and/or form levels.</p>
        <c:if test="${identity.spaceAdmin}">
            <hr />
            <h6>Advanced Management</h6>
            <p>
                Visit the <a href="${bundle.spaceLocation}/app/#/admin/space/details" target="_blank">Kinetic Request</a> 
                Management Console for advanced configuration options.
            </p>
        </c:if>
        
    </bundle:variable>
    <%-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------%>
    
</bundle:layout>