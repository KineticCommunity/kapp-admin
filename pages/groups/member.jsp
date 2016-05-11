<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<c:set var="currentKapp" value="${space.getKapp(param.kapp)}" scope="request" />
<c:set var="currentGroup" value="${GroupHelper.getGroup(param.group)}" scope="request" />
<c:set var="currentMember" value="${currentGroup.getMember(param.member)}" scope="request" />

<!-- Show page content only if Kapp & Group exist. Otherwise redirect to valid page. -->
<c:choose>
    <c:when test="${empty currentKapp}">
        <script>window.location.replace("${bundle.kappLocation}");</script>
    </c:when>
    <c:when test="${empty currentGroup}">
        <script>window.location.replace("${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}");</script>
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
                <li><a class="return-to-current-group" href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=groups/group&group=${currentGroup.id}">${currentGroup.name}</a></li>
                <li class="active ng-binding">${empty currentMember ? 'New Member' : 'Member: '}${currentMember.username}</li>
            </ol>
            
            <div class="page-header">
                <h3>
                    ${empty currentMember ? 'New Member' : 'Member: '}${currentMember.username}
                </h3>
            </div>
            
            <div class="row">
                <div class="col-xs-12">
                    <div class="member-form-container embedded-form" data-group-id="${currentGroup.id}"
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