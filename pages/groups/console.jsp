<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<%@include file="../../bundle/router.jspf" %>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <!-- Sets title and imports js and css specific to this console. -->
    <bundle:variable name="head">
        <c:import url="${bundle.path}/partials/groups/head.jsp" charEncoding="UTF-8"/>
    </bundle:variable>
    
    <!-- BREADCRUMBS START HERE. Remove if not needed. ------------------------------------------->
    <bundle:variable name="breadcrumb">
        <li class="active">${form.name}</li>
    </bundle:variable>
    <!-- BREADCRUMBS END HERE. ------------------------------------------------------------------->

    <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
                
    <div class="page-header">
        <h3>
            ${form.name}
            <span class="table-view-buttons">
                <span class="fa fa-sitemap fa-fw open" data-table="hierarchy"></span>
                <span class="fa fa-list fa-fw" data-table="flat"></span>
            </span>
            <div class="pull-right">
                <a class="btn btn-sm btn-tertiary" href="${bundle.kappLocation}/${form.slug}?page=groups/group">
                    <span class="fa fa-plus fa-fw"></span> Create Group
                </a>
            </div>
        </h3>
    </div>
    
    <c:set var="groupsFlat" value="${GroupHelper.getGroupsFlattened()}"/>
    <c:set var="groupsHierarchy" value="${GroupHelper.getGroups()}"/>

    <div class="row">
        <div class="col-xs-12">
            <c:choose>
                <c:when test="${empty groupsFlat}">
                    <div class="table no-data text-center">
                        <h4>There are no groups to display.</h4>
                        <a href="${bundle.kappLocation}/${form.slug}?page=groups/group">
                            <span class="fa fa-plus fa-fw"></span> Create Group
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
                                            <c:forEach items="${groupsHierarchy}" var="group">
                                                <c:set var="groupIterator" value="${group}" scope="request"/>
                                                <jsp:include page="../../partials/groups/groupDisplayList.jsp"/>
                                            </c:forEach>
                                        </ul>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <div class="overflow-auto">
                        <table class="table table-hover groups-table groups-table-flat"> 
                            <thead>
                                <tr>
                                    <th style="width:45%;">Group Name</th>
                                    <th style="width:10%;">Status</th>
                                    <th style="width:45%;">Parent Path</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${groupsFlat}" var="group">
                                    <tr>
                                        <td>
                                            <a href="${bundle.kappLocation}/${form.slug}?&page=groups/group&group=${group.id}">${group.displayName}</a>
                                        </td>
                                        <td><span class="label label-info">${text.titlelize(group.status)}</span></td>
                                        <td class="parent-cell" data-toggle="tooltip" title="${group.parentPathString}">${group.parentPathString}</td>
                                        </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
    
    <!-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -------------------------------->
    <bundle:variable name="aside">
        <h3>${form.name}</h3>
        <p>${form.description}</p>
        <hr class="border-color-white" />
        <p>To create a new group, click the <b class="nowrap"><span class="fa fa-plus"></span> Create Group</b> button.</p>
        <p>To manage a group and its members, click the name of the group.</p>
        <hr class="border-color-white" />
        <p>
            Use the buttons in the header to change the layout between 
            <span class="nowrap">hierarchy <span class="fa fa-sitemap"></span> view</span> and 
            <span class="nowrap">list <span class="fa fa-list"></span> view.</span>
        </p>
    </bundle:variable>
    <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
    
</bundle:layout>