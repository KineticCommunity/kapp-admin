<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<!-- Set Variables Needed To Build DOM Elements -->
<c:set var="teamsKapp" value="${space.getKapp(space.getAttributeValue('Teams Kapp Slug'))}" />
<c:set var="currentKapp" value="${space.getKapp(param.kapp)}" scope="request"/>
<c:set var="currentForm" value="${currentKapp.getForm(param.form)}" scope="request"/>
<%-- hasResponseAccess: Defines if response discussion section should be shown. --%>
<c:set var="hasResponseAccess" value="${AdminHelper.isFormOwner(identity.user, currentForm) && not empty AdminHelper.responseUrl}" scope="request" />
<c:set var="taskServerUrl" value="${space.getAttributeValue('Task Server Url')}" />
<c:set var="hasRoleFormDeveloper" value="${TeamsHelper.isMemberOfTeam(identity.user, 'Role::Form Developer')}" />
<c:set var="hasRoleTaskDeveloper" value="${TeamsHelper.isMemberOfTeam(identity.user, 'Role::Task Developer')}" />


<!-- Show page content only if selected Kapp and Form exists. -->
<c:choose>
    <c:when test="${empty currentKapp}">
        <script>window.location.replace("${bundle.kappLocation}/${form.slug}");</script>
    </c:when>
    <c:when test="${empty currentForm}">
        <script>window.location.replace("${bundle.kappLocation}/${form.slug}?page=form-management/forms&kapp=${currentKapp.slug}");</script>
    </c:when>

    <c:otherwise>
        <bundle:layout page="${bundle.path}/layouts/layout.jsp">
            <!-- Sets title and imports js and css specific to this console. -->
            <bundle:variable name="head">
                <c:import url="${bundle.path}/partials/form-management/head.jsp" charEncoding="UTF-8"/>
                <script>
                    bundle.adminFormManagement.responseUrl = "${AdminHelper.responseUrl}";
                    bundle.adminFormManagement.formSlug = "${currentForm.slug}";
                    bundle.adminFormManagement.kappSlug = "${currentKapp.slug}";
                    bundle.adminFormManagement.consoleSlug = "${form.slug}";
                    bundle.adminFormManagement.teamsKappSlug = "${teamsKapp.slug}";
                </script>
            </bundle:variable>
            
            <!-- BREADCRUMBS START HERE. Remove if not needed. ------------------------------------------->
            <bundle:variable name="breadcrumb">
                <li><a href="${bundle.kappLocation}/${form.slug}">${form.name}</a></li>
                <li><a href="${bundle.kappLocation}/${form.slug}?page=form-management/forms&kapp=${currentKapp.slug}">${text.escape(currentKapp.name)}</a></li>
                <li class="active">${text.escape(currentForm.name)}</li>
            </bundle:variable>
            <!-- BREADCRUMBS END HERE. ------------------------------------------------------------------->

            <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
            
            <div class="page-header form-activity">
                <h3>
                    <span>${text.escape(currentForm.name)}</span>
                    <small>Activity</small>
                    <div class="pull-right">
                        <c:if test="${not empty taskServerUrl && (hasRoleFormDeveloper || hasRoleTaskDeveloper)}">
                            <a class="btn btn-tertiary" href="${taskServerUrl}/app/trees?sourceGroup=${currentKapp.slug}${text.escapeUrlParameter(' > ')}${currentForm.slug}">
                                <span class="fa fa-sitemap fa-fw"></span> Edit Workflow
                            </a>
                        </c:if>
                        <a class="btn btn-tertiary" href="${bundle.kappLocation}/${form.slug}?page=form-management/form&kapp=${currentKapp.slug}&form=${currentForm.slug}">
                            <span class="fa fa-pencil fa-fw"></span> Edit Form
                        </a>
                    </div>
                </h3>
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
                    by <c:choose>
                        <c:when test="${not empty teamsKapp}">
                            <a href="${bundle.spaceLocation}/${teamsKapp.slug}?page=user&username=${text.escapeUrlParameter(currentForm.createdBy)}">${currentForm.createdBy}</a>
                        </c:when>
                        <c:otherwise>
                            <span>${currentForm.createdBy}</span>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="col-xs-12 col-sm-6">
                    <label>Updated</label>
                    <span data-moment-ago="${currentForm.updatedAt}" data-toggle="tooltip"></span>
                    by <c:choose>
                        <c:when test="${not empty teamsKapp}">
                            <a href="${bundle.spaceLocation}/${teamsKapp.slug}?page=user&username=${text.escapeUrlParameter(currentForm.updatedBy)}">${currentForm.updatedBy}</a>
                        </c:when>
                        <c:otherwise>
                            <span>${currentForm.updatedBy}</span>
                        </c:otherwise>
                    </c:choose>
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
            
            <!-- Tabs for submissions and performance -->
            <div class="form-activity-content">
                <ul class="nav nav-tabs stacked-xs" role="tablist" id="form-activity-nav">
                    <li role="presentation" class="active"><a href="#submissions" aria-controls="submissions" role="tab" data-toggle="tab">${i18n.translate('Submissions')}</a></li>
                    <li role="presentation"><a href="#performance" aria-controls="performance" role="tab" data-toggle="tab">${i18n.translate('Performance')}</a></li>
                    <li role="presentation"><a href="#feedback" aria-controls="feedback" role="tab" data-toggle="tab">${i18n.translate('Feedback')}</a></li>
                </ul>
                
                <!-- Tab panes -->
                <div class="tab-content">
                    <%-- Members --%>
                    <div role="tabpanel" class="tab-pane active" id="submissions">
                        <div class="form-activity recent-submissions">
                            <table style="width:100%" class="table table-hover table-striped dt-responsive nowrap" 
                                   id="recent-submissions-table-${currentKapp.slug}-${currentForm.slug}" 
                                   data-recent-submissions-table>
                                <tr>
                                    <td class="alert alert-info">
                                        <span class="fa fa-spinner fa-spin"></span>
                                        Loading
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>

                    <%-- Performance --%>
                    <div role="tabpanel" class="tab-pane" id="performance">
                        <img style="max-width: 100%" src="${bundle.location}/images/performance-placeholder.png" alt="Performance" />
                    </div>

                    <%-- Feedback --%>
                    <div role="tabpanel" class="tab-pane" id="feedback">
                        <h1>Coming Soon</h1>
                    </div>
                </div>
            
            </div>
            
            <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
    
            <!-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -------------------------------->
            <bundle:variable name="aside">
                
            </bundle:variable>
            <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
            
        </bundle:layout>
        
    </c:otherwise>
</c:choose>