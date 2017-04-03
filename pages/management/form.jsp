<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<c:set var="console" value="${form}" scope="request"/>
<c:set var="currentKapp" value="${space.getKapp(param.kapp)}" scope="request"/>
<c:set var="currentForm" value="${space.getKapp(param.kapp).getForm(param.form)}" scope="request"/>
<c:set var="hasResponseAccess" value="${AdminHelper.isFormOwner(identity.user, currentForm) && not empty AdminHelper.responseUrl}" scope="request" />
<c:set var="taskServerUrl" value="${space.getAttributeValue('Task Server Url')}" />
<c:set var="hasRoleFormDeveloper" value="${TeamsHelper.isMemberOfTeam(identity.user, 'Role::Form Developer')}" />
<c:set var="hasRoleTaskDeveloper" value="${TeamsHelper.isMemberOfTeam(identity.user, 'Role::Task Developer')}" />
<c:set var="catalogKapp" value="${space.getKapp(space.getAttributeValue('Catalog Kapp Slug'))}" />
<c:set var="feedbackForm" value="${catalogKapp.getForm(space.getAttributeValue('Feedback Form Slug'))}" />

<c:choose>
    <c:when test="${empty currentKapp}">
        <c:set var="error" value="${i18n.translate('No kapps with the slug SLUG exist.')
            .replace('SLUG', '<b>SLUG</b>').replace('SLUG', param.kapp)}" />
    </c:when>
    <c:when test="${empty currentForm}">
        <c:set var="error" value="${i18n.translate('No forms with the slug FORMSLUG exist in the KAPPNAME kapp.')
            .replace('FORMSLUG', '<b>FORMSLUG</b>').replace('FORMSLUG', param.form).replace('KAPPNAME', currentKapp.name)}" />
    </c:when>
</c:choose>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <%-- Sets title and imports js and css specific to this console. --%>
    <bundle:variable name="head">
        <c:import url="${bundle.path}/partials/management/head.jsp" charEncoding="UTF-8"/>
        <script>
            bundle.adminManagement.responseUrl = "${AdminHelper.responseUrl}";
            bundle.adminManagement.formSlug = "${currentForm.slug}";
            bundle.adminManagement.kappSlug = "${currentKapp.slug}";
            bundle.adminManagement.consoleSlug = "${form.slug}";
        </script>
    </bundle:variable>

    
    <%-- BREADCRUMBS START HERE. Remove if not needed. -------------------------------------------%>
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
                <li class="active">${text.escape(currentForm.name)}</li>
            </c:otherwise>
        </c:choose>
    </bundle:variable>
    <%-- BREADCRUMBS END HERE. -------------------------------------------------------------------%>

    <c:choose>
        <c:when test="${empty error}">
        
            <%-- PAGE CONTENT STARTS HERE -------------------------------------------------------%>
    
            <div class="page-header">
                <div class="row">
                    <div class="col-xs-12">
                        <h3>
                            <span>${text.escape(currentForm.name)}</span>
                            <small>Form</small>
                            <div class="pull-right users-table-buttons">
                                <a class="btn btn-tertiary" href="${bundle.kappLocation}/${console.slug}?page=management/config/form&kapp=${currentKapp.slug}&form=${currentForm.slug}">
                                    <span class="fa fa-cog fa-fw"></span> Configure Form
                                </a>
                            </div>
                        </h3>
                    </div>
                </div>
            </div>
            
            <div class="row form-activity m-b-4">
                <c:if test="${text.isNotBlank(currentForm.description)}">
                    <div class="col-xs-12">
                        <label>${i18n.translate('Description')}</label>
                        <span>${currentForm.description}</span>
                    </div>
                </c:if>
                <div class="col-xs-12 col-sm-6">
                    <label>Created</label>
                    <span data-moment-ago="${currentForm.createdAt}" data-toggle="tooltip"></span>
                    by
                    <a href="${bundle.spaceLocation}?page=user&username=${text.escapeUrlParameter(currentForm.createdBy)}">${currentForm.createdBy}</a>
                </div>
                <div class="col-xs-12 col-sm-6">
                    <label>Updated</label>
                    <span data-moment-ago="${currentForm.updatedAt}" data-toggle="tooltip"></span>
                    by 
                    <a href="${bundle.spaceLocation}?page=user&username=${text.escapeUrlParameter(currentForm.updatedBy)}">${currentForm.updatedBy}</a>
                </div>
                <div class="col-xs-12 col-sm-6">
                    <label>Status</label>
                    <span class="label ${AdminHelper.getFormStatusLabelClass(currentForm)}">${currentForm.status}</span>
                </div>
                <div class="col-xs-12 col-sm-6">
                    <label>Type</label>
                    <span>${text.defaultIfBlank(currentForm.type.name, 'N/A')}</span>
                </div>
            </div>
        
            <%-- Members of the teams who own this form can see the discussion section --%>
            <c:if test="${hasResponseAccess}">
                <c:set scope="request" var="responseId" value="${currentForm.getAttributeValue('Discussion Id')}"/>
                <div class="row form-activity response-discussion sub-heading">
                    <div class="col-xs-12 col-sm-6 col-md-8 m-t-1">
                        <span class="heading-text">Discussion</span>
                    </div>
                    <div class="col-xs-12 col-sm-6 col-md-4 m-t-1 text-right">
                        <c:choose>
                            <c:when test="${not empty responseId}">
                                <a href="${bundle.spaceLocation}?page=discussion&id=${responseId}" class="btn btn-default">Discuss</a>
                            </c:when>
                            <c:otherwise>
                                <button class="btn btn-default" id="start-discussion">Start Discussion</button>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <div class="row form-activity response-discussion m-b-4">
                    <c:choose>
                        <c:when test="${not empty responseId}">
                            <div class="col-xs-12">
                                <%-- Heading with links to parent and all ancestor teams --%>
                                <c:import url="${bundle.path}/partials/responseSummary.jsp" charEncoding="UTF-8" />
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="col-xs-12 subtle">A discussion has not yet been started.</div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </c:if>
        
            <%-- Tabs for submissions and performance --%>
            <div class="form-activity-content">
                <ul class="nav nav-tabs stacked-xs" role="tablist" id="form-activity-nav">
                    <li role="presentation" class="active"><a href="#submissions" aria-controls="submissions" role="tab" data-toggle="tab">${i18n.translate('Submissions')}</a></li>
                    <%--<li role="presentation"><a href="#performance" aria-controls="performance" role="tab" data-toggle="tab">${i18n.translate('Performance')}</a></li>--%>
                    <c:if test="${not empty feedbackForm}">
                        <li role="presentation"><a href="#feedback" aria-controls="feedback" role="tab" data-toggle="tab">${i18n.translate('Feedback')}</a></li>
                    </c:if>
                </ul>
        
                <%-- Tab panes --%>
                <div class="tab-content">
                    <%-- Submissions --%>
                    <div role="tabpanel" class="tab-pane active" id="submissions">
                        <div class="form-activity recent-submissions">
                            <table data-submissions-data-table
                                   data-source="/kapps/${currentKapp.slug}/forms/${currentForm.slug}/submissions"
                                   data-source-include="details,values,form.attributes,form.kapp.attributes"
                                   data-source-query="timeline=submittedAt&direction=DESC&coreState=Submitted&coreState=Closed"
                                   data-source-limit="25"
                                   data-order-column="3" data-order-direction="desc"
                                   style="width:100%" class="table table-hover dt-responsive nowrap" 
                                   id="recent-submissions-table-${currentKapp.slug}-${currentForm.slug}">
                                <thead>
                                    <tr>
                                        <th data-data="handle" 
                                            data-render-type="submissionManagementLink">Confirmation #</th>
                                        <th data-data="label">Submission Label</th>
                                        <th data-data="coreState"
                                            data-render-type="statusLabel">Status</th>
                                        <th data-data="submittedAt"
                                            data-render-type="submitted">Submitted</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td colspan="4" class="text-center">
                                            <span class="fa fa-spinner fa-spin"></span>
                                            Loading
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
        
                    <%-- Performance --%>
                    <div role="tabpanel" class="tab-pane" id="performance">
                        <img style="max-width: 100%" src="${bundle.location}/images/performance-placeholder.png" alt="Performance" />
                    </div>
        
                    <%-- Feedback --%>
                    <c:if test="${not empty feedbackForm}">
                        <div role="tabpanel" class="tab-pane" id="feedback">
                            <div class="form-activity feedback-activity">
                                <table data-submissions-data-table
                                       data-source="/kapps/${catalogKapp.slug}/forms/${feedbackForm.slug}/submissions"
                                       data-source-include="details,values"
                                       data-source-query="timeline=submittedAt&direction=DESC"
                                       data-source-limit="25"
                                       data-order-column="2" data-order-direction="desc"
                                       style="width:100%" class="table table-hover dt-responsive nowrap" 
                                       id="feedback-activity-table-${currentKapp.slug}-${currentForm.slug}">
                                    <thead>
                                        <tr>
                                            <th data-data="values.Comments">Comments</th>
                                            <th data-data="values.Relevant Screenshots"
                                                data-render-type="attachment">Attachments</th>
                                            <th data-data="submittedAt"
                                                data-render-type="submitted">Submitted</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td colspan="3" class="text-center">
                                                <span class="fa fa-spinner fa-spin"></span>
                                                Loading
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </c:if>
                </div>
        
            </div>
    
            <%-- PAGE CONTENT ENDS HERE ---------------------------------------------------------%>
    
            <%-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -----------------------%>
            <bundle:variable name="aside">
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
