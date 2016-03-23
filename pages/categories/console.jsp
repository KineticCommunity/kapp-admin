<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <c:set var="currentKapp" value="${space.getKapp(param.kapp)}" scope="request"/>
    <c:set var="currentConsole" value="${AdminHelper.getCurrentAdminConsole(param.page)}" scope="request"/>
    
    <!-- Sets title and imports js and css specific to this console. -->
    <bundle:variable name="head">
        <title>Admin Console<c:if test="${text.isNotEmpty(currentConsole.name)}"> | ${currentConsole.name}</c:if></title>
        <c:import url="${bundle.path}/partials/${currentConsole.slug}/head.jsp" charEncoding="UTF-8"/>
    </bundle:variable>
    
    <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
    
    <div class="page-header">
        <h3>${currentConsole.name}</h3>
    </div>
    
    <div class="manage-categories" data-slug="${currentKapp.slug}">            
        <i class="fa fa-plus add-root"> Add a category</i>
        <div class="workarea content-view-wrapper">
            <div class="pages-panel">
                <%-- For each of the categories --%>
                <ul class="sortable top">
                <!--li class="untrack">&nbsp;</li-->
                <c:forEach items="${CategoryHelper.getCategories(currentKapp)}" var="category">
                    <%-- If the category is not hidden, and it contains at least 1 form --%>
                    <c:if test="${fn:toLowerCase(category.getAttribute('Hidden').value) ne 'true'}">
                        <li data-id="${category.getName()}" data-display="${category.getDisplayName()}">
                            <span class="category">
                                ${text.escape(category.getDisplayName())}
                                <button class="btn btn-xs btn-default edit">
                                    <i class="fa fa-inverse fa-pencil"></i>
                                </button>
                            </span>
                            
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
    </div>
    <div class="add-root row" style="display: none">
        <div class="form-group">
            <div class="col-sm-4">
                <label class="">Category Name/Slug</label>
                <input name="category-name" placeholder="Category Name" id="category-name" class="form-control"> 
            </div>
            <div class="col-sm-4">
                <label class="">Display Name</label>
                <input placeholder="Display Name" id="display-name"  class="form-control"> 
            </div>
            <div class="col-sm-4">
                <button class="btn btn-success btn-sm">Add Category</button>
            </div>
        </div>
    </div>
    <div class="change-name" style="display: none">
        <div class="change-form">
            <div class="col-sm-6">
                <label class="">Category Name</label>
                <input name="change-name" placeholder="Category Name" id="change-name" class="form-control">
            </div>
            <div class="col-sm-6">
                <label class="">Display Name</label>
                <input placeholder="Display Name" id="change-display" class="form-control">
            </div>
            <div class="col-sm-12">
                <button class="btn btn-success" id="update-category">Update Category</button>
            </div>
        </div>
    </div>

    <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
    <!-- Includes right sidebar. Remove if not needed. -->
    <bundle:variable name="aside">
        <h3>TITLE</h3>
        <p>
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor 
            incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud 
            exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute 
            irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla 
            pariatur.
        </p>
    </bundle:variable>
    
</bundle:layout>