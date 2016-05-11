<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<c:set var="currentKapp" value="${space.getKapp(param.kapp)}" scope="request" />
<c:set var="currentGroup" value="${GroupHelper.getGroup(param.group)}" scope="request" />

<!-- Show page content only if Kapp & Group exist. Otherwise redirect to valid page. -->
<c:choose>
    <c:when test="${empty currentKapp}">
        <script>window.location.replace("${bundle.kappLocation}");</script>
    </c:when>
    <c:when test="${not identity.spaceAdmin}">
        <%@include file="../../partials/groups/unauthorized.jsp"%>
    </c:when>
    <c:otherwise>
    
        <bundle:layout page="${bundle.path}/layouts/layout.jsp">
            <!-- Sets title and imports js and css specific to this console. -->
            <bundle:variable name="head">
                <c:import url="${bundle.path}/partials/groups/head.jsp" charEncoding="UTF-8"/>
            </bundle:variable>

            <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
            
            <ol class="breadcrumb">
                <li><a class="return-to-groups-console" href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}">${form.name}</a></li>
                <li class="active ng-binding">${empty currentGroup ? 'New Group' : currentGroup.name}</li>
            </ol>
            
            <div class="page-header">
                <h3>
                    ${not empty currentGroup ? currentGroup.name : 'New Group'}  
                    <c:if test="${not empty currentGroup}">
                        <small> Configuration</small>
                    </c:if>
                </h3>
                <c:if test="${not empty currentGroup}">
                    <h6>
                        <c:forEach items="${currentGroup.getParentPath()}" var="parent" varStatus="status">
                            <a href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=groups/group&group=${parent.id}">${parent.name}</a>
                            <c:if test="${!status.last}">${GroupHelper.getPathDelimiter()}</c:if> 
                        </c:forEach>
                        ${GroupHelper.getPathDelimiter()} 
                        <b>${currentGroup.name}</b>
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
                                    data-parent-id="${param.parent}" data-path-delimiter="${GroupHelper.pathDelimiter}"
                                    data-parent-path="${not empty currentGroup ? currentGroup.getParentPathString() : GroupHelper.getGroup(param.parent).getPathString()}">
                                <div class="alert alert-info">
                                    <span class="fa fa-spinner fa-spin"></span>
                                    Loading
                                </div>
                            </div>
                        </div>
                    
                        <c:if test="${not empty currentGroup}"> 
                            <div role="tabpanel" class="tab-pane" id="members">
                                <div class="page-header">
                                    <h4>
                                        Members 
                                        <small> of ${currentGroup.name}</small>
                                        <div class="pull-right">
                                            <a class="btn btn-sm btn-primary" href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=groups/member&group=${currentGroup.id}">
                                                <span class="fa fa-plus fa-fw"></span> Add Member
                                            </a>
                                        </div>
                                    </h4>
                                </div>
                                <c:choose>
                                    <c:when test="${empty currentGroup.members}">
                                        <div class="table no-data text-center">
                                            <h4>${currentGroup.name} does not have any members.</h4>
                                            <a href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=groups/member&group=${currentGroup.id}">
                                                <span class="fa fa-plus fa-fw"></span> Add Member
                                            </a>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <table class="table members-table table-hover"> 
                                            <thead>
                                                <tr>
                                                    <th>Username</th>
                                                    <th>Status</th>
                                                    <th></th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach items="${currentGroup.members}" var="member">
                                                    <tr>
                                                        <td class="username" data-membership-id="${member.id}">${member.username}</td>
                                                        <td><span class="label label-info">${text.titlelize(member.status)}</span></td>
                                                        <td>
                                                            <div class="btn-group pull-right">
                                                                <a class="btn btn-xs btn-default edit" href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=groups/member&group=${currentGroup.id}&member=${member.id}">
                                                                    <span class="fa fa-pencil fa-fw"></span>
                                                                </a>
                                                                <a class="btn btn-xs btn-primary delete" href="javascript:void(0);">
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
                                <div class="page-header">
                                    <h4>
                                        Subgroups 
                                        <small> of ${currentGroup.name}</small>
                                        <div class="pull-right">
                                            <a class="btn btn-sm btn-primary" href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=groups/group&parent=${currentGroup.id}">
                                                <span class="fa fa-plus fa-fw"></span> Create Subgroup
                                            </a>
                                        </div>
                                    </h4>
                                </div>
                                <c:choose>
                                    <c:when test="${empty currentGroup.subgroups}">
                                        <div class="table no-data text-center">
                                            <h4>${currentGroup.name} does not have any subgroups.</h4>
                                            <a href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=groups/group&parent=${currentGroup.id}">
                                                <span class="fa fa-plus fa-fw"></span> Create Subgroup
                                            </a>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <table class="table groups-table groups-table-hierarchy open"> 
                                            <thead>
                                                <tr>
                                                    <th>
                                                        Group Name <small>(Type)</small>
                                                        <div class="btn-group table-hierarchy-option pull-right">
                                                            <button class="btn btn-xs btn-danger collapse-all" title="Collapse All">
                                                                <span class="fa fa-compress fa-fw"></span>
                                                            </button>
                                                            <button class="btn btn-xs btn-success expand-all" title="Expand All">
                                                                <span class="fa fa-expand fa-fw"></span>
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
                                                                <c:set var="currentGroup" value="${subgroup}" scope="request"/>
                                                                <jsp:include page="../../partials/groups/groupDisplayList.jsp"/>
                                                            </c:forEach>
                                                        </ul>
                                                    </td>
                                                </tr>
                                            </tbody>
                                        </table>
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
                TODO
            </bundle:variable>
            <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
            
        </bundle:layout>
        
    </c:otherwise>
</c:choose>