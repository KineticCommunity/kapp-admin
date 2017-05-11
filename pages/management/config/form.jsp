<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../../bundle/initialization.jspf" %>

<c:set var="console" value="${form}" scope="request"/>
<c:set var="currentKapp" value="${space.getKapp(param.kapp)}" scope="request"/>
<c:set var="currentForm" value="${currentKapp.getForm(param.form)}" scope="request"/>
<c:set var="taskServerUrl" value="${space.getAttributeValue('Task Server Url')}" />
<c:set var="hasRoleFormDeveloper" value="${TeamsHelper.isMemberOfTeam(identity.user, 'Role::Form Developer')}" />
<c:set var="hasRoleTaskDeveloper" value="${TeamsHelper.isMemberOfTeam(identity.user, 'Role::Task Developer')}" />
<c:set var="hasCustomWorkflow" value="${currentForm.hasAttributeValue('Custom Workflow on Created', 'True') 
        || currentForm.hasAttributeValue('Custom Workflow on Submitted', 'True')}" />
<c:set var="isKappOwner" value="${identity.spaceAdmin || TeamsHelper.isKappOwner(identity.user, currentKapp)}" scope="request"/>
<c:set var="isFormOwner" value="${identity.spaceAdmin || TeamsHelper.isFormOwner(identity.user, currentForm)}" scope="request"/>

<c:choose>
    <c:when test="${empty currentKapp}">
        <c:set var="error" value="${i18n.translate('No kapps with the slug SLUG exist.')
            .replace('SLUG', '<b>SLUG</b>').replace('SLUG', text.defaultIfBlank(param.kapp, ''))}" />
    </c:when>
    <c:when test="${empty currentForm}">
        <c:set var="error" value="${i18n.translate('No forms with the slug FORMSLUG exist in the KAPPNAME kapp.')
            .replace('FORMSLUG', '<b>FORMSLUG</b>').replace('FORMSLUG', text.defaultIfBlank(param.form, '')).replace('KAPPNAME', currentKapp.name)}" />
    </c:when>
    <c:when test="${(not isKappOwner && not isFormOwner) || not hasRoleFormDeveloper}">
        <c:set var="error" value="${i18n.translate('You do not have permission to configure the FORMNAME form in the KAPPNAME kapp.')
            .replace('FORMNAME', '<b>FORMNAME</b>').replace('FORMNAME', currentForm.name).replace('KAPPNAME', currentKapp.name)}" />
    </c:when>
</c:choose>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <%-- Sets title and imports js and css specific to this console. --%>
    <bundle:variable name="head">
        <c:import url="${bundle.path}/partials/management/head.jsp" charEncoding="UTF-8"/>
    </bundle:variable>

    <%-- BREADCRUMBS START HERE. Remove if not needed. ------------------------------------------%>
    <bundle:variable name="breadcrumb">
        <li><a href="${bundle.kappLocation}/${console.slug}">${console.name}</a></li>
        <c:choose>
            <c:when test="${empty currentKapp}">
                <li class="active">Kapp Not Found</li>
            </c:when>
            <c:when test="${empty currentForm}">
                <li><a href="${bundle.kappLocation}/${console.slug}?page=management/kapp&kapp=${currentKapp.slug}">${text.escape(currentKapp.name)}</a></li>
                <li class="active">Form Not Found</li>
            </c:when>
            <c:otherwise>
                <li><a href="${bundle.kappLocation}/${console.slug}?page=management/kapp&kapp=${currentKapp.slug}">${text.escape(currentKapp.name)}</a></li>
                <li><a href="${bundle.kappLocation}/${console.slug}?page=management/form&kapp=${currentKapp.slug}&form=${currentForm.slug}">${text.escape(currentForm.name)}</a></li>
                <li class="active">Configuration</li>
            </c:otherwise>
        </c:choose>
    </bundle:variable>
    <%-- BREADCRUMBS END HERE. ------------------------------------------------------------------%>

    <c:choose>
        <c:when test="${empty error}">
        
            <%-- PAGE CONTENT STARTS HERE -------------------------------------------------------%>
            
            <div class="page-header">
                <h2>
                    <span>${text.escape(currentForm.name)}</span>
                    <small>Form Configuration</small>
                    <div class="pull-right">
                        <c:if test="${not empty taskServerUrl && (identity.isSpaceAdmin() || hasRoleTaskDeveloper)}">
                            <a class="btn btn-tertiary custom-workflow-btn ${hasCustomWorkflow ? '' : 'hide'}" target="_blank" href="${taskServerUrl}/app/trees?sourceGroup=${currentKapp.slug}${text.escapeUrlParameter(' > ')}${currentForm.slug}">
                                <span class="fa fa-sitemap fa-fw"></span> Edit Workflow
                            </a>
                        </c:if>
                        <c:if test="${identity.isSpaceAdmin() || hasRoleFormDeveloper}">
                            <a class="btn btn-tertiary" target="_blank" href="${bundle.spaceLocation}/app/#/${currentKapp.slug}/author/form/${currentForm.slug}/builder">
                                <span class="fa fa-pencil fa-fw"></span> Edit Form
                            </a>
                        </c:if>
                    </div>
                </h2>
            </div>
            
            <div class="kapp-configuration-container">
                <ul class="nav nav-tabs h4 stacked-xs" role="tablist" id="form-configuration-tabs">
                    <li role="presentation" class="active"><a href="#display" aria-controls="display" role="tab" data-toggle="tab">${i18n.translate('Display Options')}</a></li>
                    <li role="presentation"><a href="#workflow" aria-controls="workflow" role="tab" data-toggle="tab">${i18n.translate('Workflow Options')}</a></li>
                    <li role="presentation"><a href="#categories" aria-controls="categories" role="tab" data-toggle="tab">${i18n.translate('Categories')}</a></li>
                </ul>
                
                <div class="tab-content">
                    
                    <%-- DISPLAY OPTIONS ----------------------------------------------------------------%>
                    <div role="tabpanel" class="tab-pane active" id="display" 
                         data-save-container data-source="/kapps/${currentKapp.slug}/forms/${currentForm.slug}" data-source-name="form"
                         data-config-partial="/config/form/display&kapp=${currentKapp.slug}&form=${currentForm.slug}">
                         
                        <c:import url="${bundle.path}/partials/management/config/form/display.jsp" charEncoding="UTF-8" />
                                        
                    </div>
                    
                    <%-- WORKFLOW OPTIONS ----------------------------------------------------------------%>
                    <div role="tabpanel" class="tab-pane" id="workflow" 
                         data-save-container data-source="/kapps/${currentKapp.slug}/forms/${currentForm.slug}" data-source-name="form"
                         data-config-partial="/config/form/workflow&kapp=${currentKapp.slug}&form=${currentForm.slug}">
                         
                        <c:import url="${bundle.path}/partials/management/config/form/workflow.jsp" charEncoding="UTF-8" />
                                        
                    </div>
                
                    <%-- CATEGORIES ----------------------------------------------------------------------%>
                    <div role="tabpanel" class="tab-pane" id="categories" 
                         data-save-container data-source="/kapps/${currentKapp.slug}/forms/${currentForm.slug}" data-source-name="form"
                         data-config-partial="/config/form/categories&kapp=${currentKapp.slug}&form=${currentForm.slug}">
                         
                        <c:import url="${bundle.path}/partials/management/config/form/categories.jsp" charEncoding="UTF-8" />
                                        
                    </div>
                
                </div>
            </div>
                
            <%-- PAGE CONTENT ENDS HERE ---------------------------------------------------------%>
    
            <%-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -----------------------%>
            <bundle:variable name="aside">
                <h3>Form Management</h3>
                <h5>${currentForm.name}</h5>
                <hr />
                <p>Here you can update different properties of the form including display options, workflow options, and categories.</p>
                <p>
                    The <b>Workflow Options</b> define configurable properties that are used by the workflow of the form.
                    <div class="p-l-2">
                        <div>The <b>Standard Workflow Process</b> uses all of the options if they are set.</div>
                        <div>If a <b>Custom Workflow Process</b> is used, the options are only used if the custom process is configured to use them.</div>
                    </div>
                </p>
                <p>The system was designed to be hierarchical so that properties configured here at the form level will override properties set at the kapp and space levels.</p>
                <p>If any properties are not configured here, the properties set at the kapp level will be used. If those properties are not set at the kapp level, the ones from the space level will be used.</p>
                <c:if test="${identity.spaceAdmin}">
                    <hr />
                    <h6>Advanced Management</h6>
                    <p>
                        Visit the <a href="${bundle.spaceLocation}/app/#/${currentKapp.slug}/author/form/${currentForm.slug}/overview" target="_blank">Kinetic Request</a> 
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

