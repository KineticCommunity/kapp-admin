<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<c:set var="console" value="${form}" scope="request"/>
<c:set var="currentSpace" value="${space}" scope="request"/>
<c:set var="currentKapp" value="${space.getKapp(param.kapp)}" scope="request"/>
<c:set var="currentForm" value="${space.getKapp(param.kapp).getForm(param.form)}" scope="request"/>

<!-- Set Variables Needed To Build DOM Elements -->
<c:set var="teamsKapp" value="${space.getKapp(space.getAttributeValue('Teams Kapp Slug'))}" />
<c:catch><c:set var="submission" value="${Submissions.retrieve(param.id)}" scope="request"/></c:catch>
<c:set var="taskServerUrl" value="${space.getAttributeValue('Task Server Url')}" />
<c:set var="hasRoleFormDeveloper" value="${TeamsHelper.isMemberOfTeam(identity.user, 'Role::Form Developer')}" />
<c:set var="hasRoleTaskDeveloper" value="${TeamsHelper.isMemberOfTeam(identity.user, 'Role::Task Developer')}" />

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <!-- Sets title and imports js and css specific to this console. -->
    <bundle:variable name="head">
        <c:import url="${bundle.path}/partials/management/head.jsp" charEncoding="UTF-8"/>
        <script>
            bundle.adminFormManagement.submissionId = "${submission.id}";
            bundle.adminFormManagement.formSlug = "${currentForm.slug}";
            bundle.adminFormManagement.kappSlug = "${currentKapp.slug}";
        </script>
    </bundle:variable>

    
    <!-- BREADCRUMBS START HERE. Remove if not needed. ------------------------------------------->
    <bundle:variable name="breadcrumb">
        <li><a href="${bundle.kappLocation}/${console.slug}">Management</a></li>
        <li><a href="${bundle.kappLocation}/${console.slug}?page=management/kapp&kapp=${currentKapp.slug}">${text.escape(currentKapp.name)}</a></li>
        <li><a href="${bundle.kappLocation}/${console.slug}?page=management/form&kapp=${currentKapp.slug}&form=${currentForm.slug}">${text.escape(currentForm.name)}</a></li>
        <li class="active">${text.escape(submission.handle)}</li>
    </bundle:variable>
    <!-- BREADCRUMBS END HERE. ------------------------------------------------------------------->

    <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
    
    <div class="page-header">
        <div class="row">
            <div class="col-xs-12">
                <h3>
                    <span>${text.escape(currentForm.name)} (${text.escape(submission.handle)})</span>
                    <div class="pull-right users-table-buttons">
                        <c:if test="${not empty taskServerUrl && (hasRoleFormDeveloper || hasRoleTaskDeveloper)}">
                            <a class="btn btn-default" href="${taskServerUrl}/app/runs?sourceId=${submission.id}">
                                <span class="fa fa-sitemap fa-fw"></span> View Runs
                            </a>
                        </c:if>
                        <a class="btn btn-tertiary" href="${bundle.kappLocation}/${console.slug}?page=management/config/form&kapp=${currentKapp.slug}&form=${currentForm.slug}">
                            <span class="fa fa-cog fa-fw"></span> Form Configuration
                        </a>
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

    <div class="row form-submission fulfillment-process sub-heading m-b-4">
        <div class="col-xs-12 m-t-1">
            <span class="heading-text">Fulfillment Process</span>
        </div>
        <div class="form-submission fulfillment-process m-b-4">
            <div class="col-xs-12 overflow-auto">
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>Form - Label</th>
                            <th>Team</th>
                            <th>User</th>
                            <th>Status</th>
                            <th>Due</th>
                            <th>Duration</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="descendant" items="${AdminHelper.formatDescendants(submission)}" varStatus="status">
                            <tr>
                                <td>
                                    <span style="padding-left: ${descendant.depth*20}px">
                                        ${descendant.submission.form.name} - ${descendant.submission.label}</td>
                                    </span>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty teamsKapp 
                                                        && text.isNotBlank(descendant.submission.values['Assigned Team']) 
                                                        && not empty TeamsHelper.getTeam(descendant.submission.values['Assigned Team'])}">
                                            <a href="${bundle.spaceLocation}/${teamsKapp.slug}?page=team&team=${TeamsHelper.getTeam(descendant.submission.values['Assigned Team']).slug}">
                                                ${descendant.submission.values['Assigned Team']}
                                            </a>
                                        </c:when>
                                        <c:otherwise>
                                            ${descendant.submission.values['Assigned Team']}
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${text.isNotBlank(descendant.submission.values['Assigned Individual'])}">
                                            <a href="${bundle.spaceLocation}?page=user&username=${text.escapeUrlParameter(descendant.submission.values['Assigned Individual'])}">
                                                ${descendant.submission.values['Assigned Individual']}
                                            </a>
                                        </c:when>
                                        <c:otherwise>
                                            ${descendant.submission.values['Assigned Individual']}
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>${descendant.submission.values['Status']}</td>
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
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <div class="row form-submission submission-activity sub-heading">
        <div class="col-xs-12 m-t-1">
            <span class="heading-text">Submission Activity</span>
        </div>
        <div class="form-submission submission-activity m-b-4">
            <div class="col-xs-12 overflow-auto">
                <table class="table table-striped">
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
            </div>
        </div>
    </div>

    <div class="row form-submission submission-values sub-heading">
        <div class="col-xs-12 m-t-1">
            <span class="heading-text">Values</span>
        </div>
        <div class="form-submission submission-values m-b-4">
            <div class="col-xs-12 overflow-auto">
                <table class="table table-striped">
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

    <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>

    <!-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -------------------------------->
    <bundle:variable name="aside">
    </bundle:variable>
    <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
    
</bundle:layout>
