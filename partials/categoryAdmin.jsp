<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../bundle/initialization.jspf" %>

<section class="menu">
    <ul class="nav nav-pills kapp-select">
        <c:forEach items="${space.kapps}" var="kapp">
            <li role="presentation" data-slug="${kapp.slug}">
                <a href="#tab-${kapp.slug}" aria-controls="tab-${kapp.slug}" role="tab" data-toggle="tab">${kapp.name}</a>
            </li>
        </c:forEach>
    </ul>
</section>
<div class="tab-content">
    <c:forEach items="${space.kapps}" var="kapp2">
        <div role="tabpanel" class="tab-pane" id="tab-${kapp2.slug}">            
            <i class="fa fa-plus add-root"> Add a category</i>
            <div class="workarea">
                <%-- For each of the categories --%>
                <ul class="sortable top">
                <!--li class="untrack">&nbsp;</li-->
                <c:forEach items="${CategoryHelper.getCategories(kapp2)}" var="category">
                    <%-- If the category is not hidden, and it contains at least 1 form --%>
                    <c:if test="${fn:toLowerCase(category.getAttribute('Hidden').value) ne 'true'}">
                        <li data-id="${category.getName()}" data-display="${category.getDisplayName()}">
                            <strong>${text.escape(category.getDisplayName())} <i class="fa fa-pencil edit"></i></strong>
                            <ul class="subcategories sortable">
                                <!--i class="target">Drop here to add a sub-category</i-->
                                <%-- Recursive Subcatgegories --%>
                                <c:set scope="request" var="thisCat" value="${category}"/>
                                <c:import url="${bundle.path}/partials/subCategoryLi.jsp" charEncoding="UTF-8" />
                            </ul>
                        </li>
                    </c:if>
                </c:forEach>
                </ul>
            </div>
        </div>
    </c:forEach>
    <div class="add-root" style="display: none">
        <div><input name="category-name" placeholder="Category Name" id="category-name"> <input placeholder="Display Name" id="display-name"> <button>Add Category</button></div>
    </div>
    <div class="change-name" style="display: none">
        <div class="change-form"><input name="change-name" placeholder="Category Name" id="change-name"> <input placeholder="Display Name" id="change-display"> <button id="update-category">Update Category</button></div>
    </div>
</div>
