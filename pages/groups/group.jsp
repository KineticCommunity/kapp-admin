<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<c:set var="currentGroup" value="${GroupHelper.getGroupById(param.group)}" scope="request" />
<c:set var="parentGroup" value="${GroupHelper.getGroupById(param.parent)}" scope="request" />

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <!-- Sets title and imports js and css specific to this console. -->
    <bundle:variable name="head">
        <c:import url="${bundle.path}/partials/groups/head.jsp" charEncoding="UTF-8"/>
    </bundle:variable>
    
    <!-- BREADCRUMBS START HERE. Remove if not needed. ------------------------------------------->
    <bundle:variable name="breadcrumb">
        <li><a class="return-to-groups-console" href="${bundle.kappLocation}/${form.slug}">${form.name}</a></li>
        <li class="active ng-binding">${empty currentGroup ? 'New Group' : currentGroup.displayName}</li>
    </bundle:variable>
    <!-- BREADCRUMBS END HERE. ------------------------------------------------------------------->

    <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
    
    <div class="page-header">
        <h3>
            ${not empty currentGroup ? currentGroup.displayName : 'New Group'}  
            <c:if test="${not empty currentGroup}">
                <small> Configuration</small>
            </c:if>
        </h3>
        <c:if test="${not empty currentGroup}">
            <h6>
                <c:forEach items="${currentGroup.getParentPath()}" var="parent" varStatus="status">
                    <a href="${bundle.kappLocation}/${form.slug}?page=groups/group&group=${parent.id}">${parent.displayName}</a>
                    <c:if test="${!status.last}">${GroupHelper.getPathDelimiter()}</c:if> 
                </c:forEach>
                ${GroupHelper.getPathDelimiter()} 
                <b>${currentGroup.displayName}</b>
            </h6>
        </c:if>
    </div>
    
    <div class="row">
        <div class="col-xs-12">
            <c:if test="${not empty currentGroup}"> 
                <div class="group-tab-navigation">
                    <ul class="nav nav-pills sub-nav" role="tablist">
                        <li role="presentation" class="active">
                            <a href="#general" aria-controls="home" role="tab" data-toggle="tab">General</a>
                        </li>
                        <li>
                            <a href="#members" aria-controls="home" role="tab" data-toggle="tab">Members</a>
                        </li>
                        <li>
                            <a href="#subgroups" aria-controls="home" role="tab" data-toggle="tab">Subgroups</a>
                        </li>
                    </ul>
                </div>
            </c:if>
            
            <div class="tab-content groups-tab-content">
            
                <div role="tabpanel" class="tab-pane active" id="general">
                    <div class="group-form-container embedded-form" data-group-id="${currentGroup.id}" data-has-subgroups="${currentGroup.hasSubgroups()}"
                            data-parent-id="${param.parent}" data-parent-name="${parentGroup.name}" data-path-delimiter="${GroupHelper.pathDelimiter}"
                            data-parent-path="${not empty currentGroup ? currentGroup.getParentPathString() : parentGroup.getPathString()}">
                        <div class="alert alert-info">
                            <span class="fa fa-spinner fa-spin"></span>
                            Loading
                        </div>
                    </div>
                </div>
            
                <c:if test="${not empty currentGroup}"> 
                    <div role="tabpanel" class="tab-pane" id="members">
                        <div class="page-header clearfix">
                            <h4>
                                Members 
                                <small> of ${currentGroup.displayName}</small>
                                <div class="pull-right">
                                    <a class="btn btn-sm btn-tertiary" href="${bundle.kappLocation}/${form.slug}?page=groups/member&group=${currentGroup.id}">
                                        <span class="fa fa-plus fa-fw"></span> Add Member
                                    </a>
                                </div>
                            </h4>
                        </div>
                        <c:choose>
                            <c:when test="${empty currentGroup.members}">
                                <div class="table no-data text-center">
                                    <h4>${currentGroup.displayName} does not have any members.</h4>
                                    <a href="${bundle.kappLocation}/${form.slug}?page=groups/member&group=${currentGroup.id}">
                                        <span class="fa fa-plus fa-fw"></span> Add Member
                                    </a>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <table class="table members-table table-hover" data-group-id="${currentGroup.id}" data-group-name="${currentGroup.name}"> 
                                    <thead>
                                        <tr>
                                            <th>Username</th>
                                            <th></th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach items="${currentGroup.members}" var="member">
                                            <tr>
                                                <td class="username" data-membership-id="${member.id}">${member.username}</td>
                                                <td>
                                                    <div class="btn-group pull-right">
                                                        <a class="btn btn-xs btn-danger delete" href="javascript:void(0);">
                                                            <span class="fa fa-times fa-fw"></span>
                                                        </a>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    
                    <div role="tabpanel" class="tab-pane" id="subgroups">
                        <div class="page-header clearfix">
                            <h4>
                                Subgroups 
                                <small> of ${currentGroup.displayName}</small>
                                <div class="pull-right">
                                    <a class="btn btn-sm btn-tertiary" href="${bundle.kappLocation}/${form.slug}?page=groups/group&parent=${currentGroup.id}">
                                        <span class="fa fa-plus fa-fw"></span> Create Subgroup
                                    </a>
                                </div>
                            </h4>
                        </div>
                        <c:choose>
                            <c:when test="${empty currentGroup.subgroups}">
                                <div class="table no-data text-center">
                                    <h4>${currentGroup.displayName} does not have any subgroups.</h4>
                                    <a href="${bundle.kappLocation}/${form.slug}?page=groups/group&parent=${currentGroup.id}">
                                        <span class="fa fa-plus fa-fw"></span> Create Subgroup
                                    </a>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="overflow-auto">
                                    <table class="table groups-table groups-table-hierarchy open"> 
                                        <thead>
                                            <tr>
                                                <th>
                                                    Group Name
                                                    <div class="btn-group table-hierarchy-option pull-right">
                                                        <button class="btn btn-xs btn-subtle collapse-all" title="Collapse All">
                                                            <span class="fa fa-compress fa-fw"></span> Collapse All
                                                        </button>
                                                        <button class="btn btn-xs btn-subtle expand-all" title="Expand All">
                                                            <span class="fa fa-expand fa-fw"></span> Expand All
                                                        </button>
                                                    </div>
                                                </th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr>
                                                <td>
                                                    <ul>
                                                        <c:forEach items="${currentGroup.subgroups}" var="subgroup">
                                                            <c:set var="groupIterator" value="${subgroup}" scope="request"/>
                                                            <jsp:include page="../../partials/groups/groupDisplayList.jsp"/>
                                                        </c:forEach>
                                                    </ul>
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </c:if>  
            </div>
        </div>
    </div>
    
    <!-- GROUP DATA AS JSON STRING - HIDDEN AND USED BY JAVASCRIPT -->
    <div class="group-data-json hide">${json.toString(GroupHelper.getGroupsFlattenedJson())}</div>

    <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
    
    <!-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -------------------------------->
    <bundle:variable name="aside">
        <h3>${form.name}</h3>
        <h4>${not empty currentGroup ? currentGroup.displayName : 'New Group'}</h4>
        <p>${currentGroup.description}</p>
        <hr class="border-color-white" />
        <c:choose>
            <c:when test="${not empty currentGroup}">
                <p>The <b>General</b> tab allows you to update the details of the group.</p>
                <div class="p-l-2">
                    <p>
                        To change the parent of the group, click the edit <b><span class="fa fa-pencil"></span></b> button.
                        Then use the remove <b><span class="fa fa-times"></span></b> button and the 
                        <b class="nowrap"><span class="fa fa-plus"></span> Add Parent</b> button to update the parent path. 
                    </p>
                    <p>To delete a group, click the <b>Delete Group</b> link.</p>
                    <p><span class="fa fa-exclamation-circle"></span> You may not delete a group that has subgroups.</p>
                </div>
                <hr class="border-color-white" />
                <p>The <b>Members</b> tab allows you to manage the members of this group.</p>
                <div class="p-l-2">
                    <p>To add a member, click the <b class="nowrap"><span class="fa fa-plus"></span> Add Member</b> button.</p>
                    <p>To remove a member, click the remove <b><span class="fa fa-times"></span></b> button.</p>
                </div>
                <hr class="border-color-white" />
                <p>The <b>Subgroups</b> tab allows you to see the subgroups of this group.</p>
                <div class="p-l-2">
                    <p>To create a new subgroup, click the <b class="nowrap"><span class="fa fa-plus"></span> Create Subgroup</b> button.</p>
                    <p>To manage a subgroup and its members, click the name of the subgroup.</p>
                </div>
            </c:when>
            <c:otherwise>
                <p>
                    To change the parent of the group, click the edit <b><span class="fa fa-pencil"></span></b> button.
                    Then use the remove <b><span class="fa fa-times"></span></b> button and the 
                    <b class="nowrap"><span class="fa fa-plus"></span> Add Parent</b> button to update the parent path. 
                </p>
            </c:otherwise>
        </c:choose>
    </bundle:variable>
    <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->

</bundle:layout>