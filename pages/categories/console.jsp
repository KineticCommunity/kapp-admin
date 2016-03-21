<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <!-- Set currentConsole (AdminConsole) and currentKapp (Kapp) for later use in building the page. -->
    <c:set var="currentConsole" value="${AdminHelper.getCurrentAdminConsole(param.page)}" scope="request"/>
    <c:choose>
        <c:when test="${empty space.getKapp(param.kapp) && not empty space.kapps}">
            <c:set var="currentKapp" value="${space.kapps[0]}" scope="request"/>
        </c:when>
        <c:otherwise>
            <c:set var="currentKapp" value="${space.getKapp(param.kapp)}" scope="request"/>
        </c:otherwise>
    </c:choose>
    
    <!-- Sets title and imports js and css specific to this console. -->
    <bundle:variable name="head">
        <title>Admin Console<c:if test="${text.isNotEmpty(currentConsole.name)}"> | ${currentConsole.name}</c:if></title>
        <c:import url="${bundle.path}/partials/categories/head.jsp" charEncoding="UTF-8"/>
    </bundle:variable>
    
    <!-- Includes the sidebar navigation (Kapp navigation by default). Remove if not needed. -->
    <bundle:variable name="sidebar">
        <c:import url="${bundle.path}/partials/sidebarKapps.jsp" charEncoding="UTF-8"/>
    </bundle:variable>
    
    <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
    
    <div class="page-header">
        <h3>${currentKapp.name}</h3>
    </div>
    
    <div class="manage-categories" data-slug="${currentKapp.slug}">            
        <i class="fa fa-plus add-root"> Add a category</i>
        <div class="workarea">
            <%-- For each of the categories --%>
            <ul class="sortable top">
            <!--li class="untrack">&nbsp;</li-->
            <c:forEach items="${CategoryHelper.getCategories(currentKapp)}" var="category">
                <%-- If the category is not hidden, and it contains at least 1 form --%>
                <c:if test="${fn:toLowerCase(category.getAttribute('Hidden').value) ne 'true'}">
                    <li data-id="${category.getName()}" data-display="${category.getDisplayName()}">
                        <strong>${text.escape(category.getDisplayName())} <i class="fa fa-pencil edit"></i></strong>
                        <ul class="subcategories sortable">
                            <!--i class="target">Drop here to add a sub-category</i-->
                            <%-- Recursive Subcatgegories --%>
                            <c:set scope="request" var="thisCat" value="${category}"/>
                            <c:import url="${bundle.path}/partials/categories/subCategoryLi.jsp" charEncoding="UTF-8" />
                        </ul>
                    </li>
                </c:if>
            </c:forEach>
            </ul>
        </div>
    </div>
    <div class="add-root" style="display: none">
        <div><input name="category-name" placeholder="Category Name" id="category-name"> <input placeholder="Display Name" id="display-name"> <button>Add Category</button></div>
    </div>
    <div class="change-name" style="display: none">
        <div class="change-form"><input name="change-name" placeholder="Category Name" id="change-name"> <input placeholder="Display Name" id="change-display"> <button id="update-category">Update Category</button></div>
    </div>

    <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
    
</bundle:layout>