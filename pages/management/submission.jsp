<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<c:set var="console" value="${form}" scope="request"/>
<c:catch><c:set var="submission" value="${Submissions.retrieve(param.id)}" scope="request"/></c:catch>
<c:set var="currentKapp" value="${not empty submission.form.kapp ? submission.form.kapp : space.getKapp(param.kapp)}" scope="request"/>
<c:set var="currentForm" value="${not empty submission.form ? submission.form : currentKapp.getForm(param.form)}" scope="request"/>

<%-- Set Variables Needed To Build DOM Elements --%>
<c:set var="teamsKapp" value="${space.getKapp(space.getAttributeValue('Teams Kapp Slug'))}" />
<c:set var="taskServerUrl" value="${space.getAttributeValue('Task Server Url')}" />
<c:set var="hasRoleFormDeveloper" value="${TeamsHelper.isMemberOfTeam(identity.user, 'Role::Form Developer')}" />
<c:set var="hasRoleTaskDeveloper" value="${TeamsHelper.isMemberOfTeam(identity.user, 'Role::Task Developer')}" />

<c:choose>
    <c:when test="${empty submission}">
        <c:set var="error" value="${i18n.translate('The submission with the specified id does not exist.')}" />
    </c:when>
    <c:when test="${empty currentKapp}">
        <c:set var="error" value="${i18n.translate('No kapps with the slug SLUG exist.')
            .replace('SLUG', '<b>SLUG</b>').replace('SLUG', text.defaultIfBlank(param.kapp, ''))}" />
    </c:when>
    <c:when test="${empty currentForm}">
        <c:set var="error" value="${i18n.translate('No forms with the slug FORMSLUG exist in the KAPPNAME kapp.')
            .replace('FORMSLUG', '<b>FORMSLUG</b>').replace('FORMSLUG', text.defaultIfBlank(param.form, '')).replace('KAPPNAME', text.defaultIfBlank(currentKapp.name, ''))}" />
    </c:when>
</c:choose>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <%-- Sets title and imports js and css specific to this console. --%>
    <bundle:variable name="head">
        <c:import url="${bundle.path}/partials/management/head.jsp" charEncoding="UTF-8"/>
        <script>
            bundle.adminManagement.submissionId = "${submission.id}";
            bundle.adminManagement.formSlug = "${currentForm.slug}";
            bundle.adminManagement.kappSlug = "${currentKapp.slug}";
        </script>
    </bundle:variable>

    
    <%-- BREADCRUMBS START HERE. Remove if not needed. -------------------------------------------%>
    <bundle:variable name="breadcrumb">
        <li><a href="${bundle.kappLocation}/${console.slug}">Management</a></li>
        <c:choose>
            <c:when test="${empty submission}">
                <li class="active">Submission Not Found</li>
            </c:when>
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
                <li class="active">${text.escape(submission.handle)}</li>
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
                            <span>${text.escape(currentForm.name)} (${text.escape(submission.handle)})</span>
                            <div class="pull-right users-table-buttons">
                                <c:if test="${not empty taskServerUrl && (identity.isSpaceAdmin() || hasRoleFormDeveloper || hasRoleTaskDeveloper)}">
                                    <a class="btn btn-default" href="${taskServerUrl}/app/runs?sourceId=${submission.id}">
                                        <span class="fa fa-sitemap fa-fw"></span> View Runs
                                    </a>
                                </c:if>
                            </div>
                        </h3>
                    </div>
                </div>
            </div>
            
            <div class="row form-activity m-b-4">
                <div class="col-xs-12">
                    <label>${i18n.translate('Submission Id')}</label>
                    <span>${submission.id}</span>
                </div>
                <div class="col-xs-12 col-sm-6">
                    <label>Status</label>
                    <span class="label ${SubmissionHelper.getStatusClass(submission)}">${SubmissionHelper.getStatus(submission)}</span>
                </div>
                <div class="col-xs-12 col-sm-6">
                    <label>Time to Close</label>
                    <c:choose>
                        <c:when test="${empty submission.closedAt}">
                            Not closed yet
                        </c:when>
                        <c:when test="${not empty submission.submittedAt}">
                            <span data-moment-diff-start="${submission.submittedAt}" data-moment-diff-end="${submission.closedAt}"></span>
                        </c:when>
                        <c:otherwise>
                            <span data-moment-diff-start="${submission.createdAt}" data-moment-diff-end="${submission.closedAt}"></span>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="col-xs-12 col-sm-6">
                    <label>Created</label>
                    <span data-moment-ago="${submission.createdAt}" data-toggle="tooltip"></span>
                    by 
                    <a href="${bundle.spaceLocation}?page=user&username=${text.escapeUrlParameter(submission.createdBy)}">${submission.createdBy}</a>
                </div>
                <div class="col-xs-12 col-sm-6">
                    <label>Submitted</label>
                    <c:choose>
                        <c:when test="${not empty submission.submittedAt}">
                            <span data-moment-ago="${submission.submittedAt}" data-toggle="tooltip"></span>
                            by 
                            <a href="${bundle.spaceLocation}?page=user&username=${text.escapeUrlParameter(submission.submittedBy)}">${submission.submittedBy}</a>
                        </c:when>
                        <c:otherwise>
                            N/A
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="col-xs-12 col-sm-6">
                    <label>Updated</label>
                    <span data-moment-ago="${submission.updatedAt}" data-toggle="tooltip"></span>
                    by 
                    <a href="${bundle.spaceLocation}?page=user&username=${text.escapeUrlParameter(submission.updatedBy)}">${submission.updatedBy}</a>
                </div>
                <div class="col-xs-12 col-sm-6">
                    <label>Closed</label>
                    <c:choose>
                        <c:when test="${not empty submission.closedAt}">
                            <span data-moment-ago="${submission.closedAt}" data-toggle="tooltip"></span>
                            by 
                            <a href="${bundle.spaceLocation}?page=user&username=${text.escapeUrlParameter(submission.closedBy)}">${submission.closedBy}</a>
                        </c:when>
                        <c:otherwise>
                            N/A
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        
            <div class="row form-submission fulfillment-process sub-heading">
                <div class="col-xs-12 m-t-1">
                    <span class="heading-text">Fulfillment Process</span>
                </div>
                <div class="form-submission fulfillment-process m-b-4">
                    <div class="col-xs-12 overflow-auto">
                        <c:set var="descendants" value="${AdminHelper.formatDescendants(submission)}" />
                        <c:choose>
                            <c:when test="${not empty descendants}">
                                <table class="table">
                                    <thead>
                                        <tr>
                                            <th>Submission</th>
                                            <th>Assignment</th>
                                            <th>Status</th>
                                            <th>Due</th>
                                            <th>Duration</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="descendant" items="${descendants}" varStatus="status">
                                            <tr>
                                                <td>
                                                    <span style="padding-left: ${descendant.depth*20}px">
                                                        <a href="${bundle.kappLocation}/${console.slug}?page=management/submission&id=${descendant.submission.id}">
                                                            ${descendant.submission.form.name} (${descendant.submission.handle})
                                                        </a>
                                                    </span>
                                                </td>
                                                <td>
                                                    <c:set var="assignedTeam" value="${descendant.submission.values['Assigned Team']}" />
                                                    <c:set var="assignedIndividual" value="${descendant.submission.values['Assigned Individual']}" />
                                                    <c:choose>
                                                        <c:when test="${not empty teamsKapp && text.isNotBlank(assignedTeam) 
                                                                        && not empty TeamsHelper.getTeam(assignedTeam)}">
                                                            <a href="${bundle.spaceLocation}/${teamsKapp.slug}?page=team&team=${TeamsHelper.getTeam(assignedTeam).slug}">
                                                                ${assignedTeam}
                                                            </a>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span>${assignedTeam}</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <c:if test="${text.isNotBlank(assignedTeam) && text.isNotBlank(assignedIndividual)}">
                                                        <span>&gt;</span>
                                                    </c:if>
                                                    <c:choose>
                                                        <c:when test="${text.isNotBlank(assignedIndividual)}">
                                                            <a href="${bundle.spaceLocation}?page=profile&username=${text.escapeUrlParameter(assignedIndividual)}">
                                                                ${assignedIndividual}
                                                            </a>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span>${assignedIndividual}</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td><span class="label ${SubmissionHelper.getStatusClass(descendant.submission)}">${SubmissionHelper.getStatus(descendant.submission)}</span></td>
                                                <td>
                                                    <c:if test="${text.isNotBlank(descendant.submission.values['Due Date'])}">
                                                        <c:set var="pastDue" value="${!text.equals(descendant.submission.coreState, 'Closed') && time.parse(descendant.submission.values['Due Date']).isBefore(time.now())}" />
                                                        <span data-moment-ago="${descendant.submission.values['Due Date']}" data-toggle="tooltip" class="${pastDue ? 'text-danger' : ''}"></span>
                                                    </c:if>
                                                </td>
                                                <td>
                                                    <span data-moment-diff-start="${text.equals(submission.type, 'Service') && not empty submission.submittedAt ? submission.submittedAt : submission.createdAt}" 
                                                          data-moment-diff-end="${not empty submission.closedAt ? submission.closedAt : ''}"></span>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="5" class="row-footer">
                                                    <span style="padding-left: ${descendant.depth*20}px">
                                                        ${descendant.submission.label}
                                                    </span>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </c:when>
                            <c:otherwise>
                                <em>There are no fulfillment steps</em>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        
            <div class="row form-submission submission-activity sub-heading">
                <div class="col-xs-12 m-t-1">
                    <span class="heading-text">Submission Activity</span>
                </div>
                <div class="form-submission submission-activity m-b-4">
                    <div class="col-xs-12 overflow-auto">
                        <c:choose>
                            <c:when test="${not empty submission.activities}">
                                <table class="table">
                                    <thead>
                                        <tr>
                                            <th>Type</th>
                                            <th>Label</th>
                                            <th>Description</th>
                                            <th>Data</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="activity" items="${submission.activities}">
                                            <tr>
                                                <td>${activity.type}</td>
                                                <td>${activity.label}</td>
                                                <td>${activity.description}</td>
                                                <td>
                                                    <c:catch>
                                                        <c:set var="activityData" value="${json.parse(activity.data)}" />
                                                    </c:catch>
                                                    <c:choose>
                                                        <c:when test="${not empty activityData}">
                                                            <c:forEach var="datum" items="${activityData}">
                                                                <div>
                                                                    <span>${datum.key}:</span>
                                                                    <span>${datum.value}</span>
                                                                </div>
                                                            </c:forEach>
                                                        </c:when>
                                                        <c:otherwise>
                                                            ${activity.data}
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <c:remove var="activityData" />
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </c:when>
                            <c:otherwise>
                                <em>There is no submission activity</em>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        
            <div class="row form-submission submission-values sub-heading">
                <div class="col-xs-12 m-t-1">
                    <span class="heading-text">Values</span>
                </div>
                <div class="form-submission submission-values m-b-4">
                    <div class="col-xs-12 overflow-auto">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>Field</th>
                                    <th>Value</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="field" items="${submission.values}">
                                    <tr>
                                        <td>${field.key}</td>
                                        <td>${field.value}</td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
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