<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<c:forEach var="subcategory" items="${thisCat.getSubcategories()}">
    <li data-id="${subcategory.getName()}" data-display="${subcategory.getDisplayName()}">
        <div class="category">
            <div>${text.escape(subcategory.getDisplayName())}</div>
            <button class="btn btn-xs btn-danger delete pull-right" style="display: none;">
                <i class="fa fa-inverse fa-close"></i>
            </button>
        </div>
        <ul class="subcategories sortable">
            <c:set var="thisCat" value="${subcategory}" scope="request"/>
            <jsp:include page="subCategoryLi.jsp"/>
        </ul>
    </li>
</c:forEach>