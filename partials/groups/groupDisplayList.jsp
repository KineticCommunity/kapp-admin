<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<li class="group-item open ${currentGroup.hasSubgroups() ? 'has-subgroups' : ''}" data-group-id="${currentGroup.id}">
    <a href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=groups/group&group=${currentGroup.id}">${currentGroup.displayName}</a>
    <span class="pull-right status"><span class="label label-info">${text.titlelize(currentGroup.status)}</span></span>
</li>
<c:if test="${currentGroup.hasSubgroups()}">
    <li class="subgroup-item open" data-group-id="${currentGroup.id}">
        <ul>
            <c:forEach items="${currentGroup.subgroups}" var="group">
                <c:set var="currentGroup" value="${group}" scope="request"/>
                <jsp:include page="../../partials/groups/groupDisplayList.jsp"/>
            </c:forEach>
        </ul>
    </li>
</c:if>
