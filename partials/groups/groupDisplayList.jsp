<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<li class="group-item clearfix open ${groupIterator.hasSubgroups() ? 'has-subgroups' : ''}" data-group-id="${groupIterator.id}">
    <a href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=groups/group&group=${groupIterator.id}">${groupIterator.displayName}</a>
    <span class="pull-right status"><span class="label label-info">${text.titlelize(groupIterator.status)}</span></span>
</li>
<c:if test="${groupIterator.hasSubgroups()}">
    <li class="subgroup-item open" data-group-id="${groupIterator.id}">
        <ul>
            <c:forEach items="${groupIterator.subgroups}" var="group">
                <c:set var="groupIterator" value="${group}" scope="request"/>
                <jsp:include page="../../partials/groups/groupDisplayList.jsp"/>
            </c:forEach>
        </ul>
    </li>
</c:if>
