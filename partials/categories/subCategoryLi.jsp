<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<c:forEach var="subcategory" items="${thisCat.getSubcategories()}">
    <li data-id="${subcategory.getName()}" data-display="${subcategory.getDisplayName()}">
        <span class="category">
            ${text.escape(subcategory.getDisplayName())}
            <button class="btn btn-xs btn-default edit">
                <i class="fa fa-inverse fa-pencil"></i>
            </button>
        </span>
        <ul class="subcategories sortable">
            <c:set var="thisCat" value="${subcategory}" scope="request"/>
            <jsp:include page="subCategoryLi.jsp"/>
        </ul>
    </li>
</c:forEach>