<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<%@include file="../../bundle/router.jspf" %>
<c:set var="currentKapp" value="${space.getKapp(param.kapp)}" scope="request" />

<!-- Show page content only if Kapp exists. Otherwise redirect to valid page. -->
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
                        
            <div class="page-header">
                <h3>
                    ${form.name}
                    <span class="table-view-buttons">
                        <span class="fa fa-list fa-fw open" data-table="flat"></span>
                        <span class="fa fa-sitemap fa-fw" data-table="hierarchy"></span>
                    </span>
                    <div class="pull-right">
                        <a class="btn btn-sm btn-primary" href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=groups/group">
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
                                <a href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=groups/group">
                                    <span class="fa fa-plus fa-fw"></span> Create Group
                                </a>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <table class="table table-hover groups-table groups-table-flat open"> 
                                <thead>
                                    <tr>
                                        <th>Group Name <small>(Type)</small></th>
                                        <th>Status</th>
                                        <th>Parent Path</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach items="${groupsFlat}" var="group">
                                        <tr>
                                            <td>
                                                <a href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=groups/group&group=${group.id}">${group.name}</a>
                                                <small>(${group.type})</small>
                                            </td>
                                            <td><span class="label label-info">${text.titlelize(group.status)}</span></td>
                                            <td class="parent-cell" data-toggle="tooltip" title="${group.parentPathString}">${group.parentPathString}</td>
                                            </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                            <table class="table groups-table groups-table-hierarchy"> 
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
                                                <c:forEach items="${groupsHierarchy}" var="group">
                                                    <c:set var="currentGroup" value="${group}" scope="request"/>
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
            </div>
        
            <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
            
            <!-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -------------------------------->
            <bundle:variable name="aside">
                <h3>Group Management</h3>
                <p>
                    Group Management allows administrators to manage groups and their members.
                </p>
                <hr />
            </bundle:variable>
            <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
            
        </bundle:layout>
        
    </c:otherwise>
</c:choose>