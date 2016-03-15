<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../bundle/initialization.jspf" %>
<c:forEach var="subcategory" items="${thisCat.getSubcategories()}">
    <li data-id="${subcategory.getName()}" data-display="${subcategory.getDisplayName()}">
        <strong>${text.escape(subcategory.getDisplayName())} <i class="fa fa-pencil edit"></i></strong>
        <ul class="sortable">
            <!--i class="target">Drop here to add a sub-category</i-->
            <c:set var="thisCat" value="${subcategory}" scope="request"/>
            <jsp:include page="subCategoryLi.jsp"/>
        </ul>
    </li>
</c:forEach>