<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<c:set var="currentGroup" value="${GroupHelper.getGroupById(param.group)}" scope="request" />
<c:set var="currentMember" value="${currentGroup.getMember(param.member)}" scope="request" />

<!-- Show page content only if Group exists. Otherwise redirect to Group Management home page. -->
<c:choose>
    <c:when test="${empty currentGroup}">
        <script>window.location.replace("${bundle.kappLocation}/${form.slug}");</script>
    </c:when>
    <c:otherwise>
    
        <bundle:layout page="${bundle.path}/layouts/layout.jsp">
            <!-- Sets title and imports js and css specific to this console. -->
            <bundle:variable name="head">
                <c:import url="${bundle.path}/partials/groups/head.jsp" charEncoding="UTF-8"/>
            </bundle:variable>
    
            <!-- BREADCRUMBS START HERE. Remove if not needed. ------------------------------------------->
            <bundle:variable name="breadcrumb">
                <li><a class="return-to-groups-console" href="${bundle.kappLocation}/${form.slug}">${form.name}</a></li>
                <li><a class="return-to-current-group" href="${bundle.kappLocation}/${form.slug}?page=groups/group&group=${currentGroup.id}">${currentGroup.displayName}</a></li>
                <li class="active">${empty currentMember ? 'New Member' : 'Member: '}${currentMember.username}</li>
            </bundle:variable>
            <!-- BREADCRUMBS END HERE. ------------------------------------------------------------------->

            <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
            
            <div class="page-header">
                <h3>
                    ${empty currentMember ? 'New Member' : 'Member: '}${currentMember.username}
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
                    <div class="member-form-container embedded-form" data-group-id="${currentGroup.id}" data-group-name="${currentGroup.name}"
                            data-member-id="${currentMember.id}" data-member-username="${currentMember.username}">
                        <div class="alert alert-info">
                            <span class="fa fa-spinner fa-spin"></span>
                            Loading
                        </div>
                    </div>
                </div>
            </div>
        
            <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
            
        </bundle:layout>
        
    </c:otherwise>
</c:choose>