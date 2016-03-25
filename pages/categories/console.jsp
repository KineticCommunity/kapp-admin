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
    
    <div class="manage-categories col-sm-8" data-slug="${currentKapp.slug}">            
        <div class="workarea content-view-wrapper">
            <div class="pages-panel">
                <%-- For each of the categories --%>
                <ul class="sortable top">
                <c:forEach items="${CategoryHelper.getCategories(currentKapp)}" var="category">
                    <li data-id="${category.getName()}" data-display="${category.getDisplayName()}">
                        <div class="category">
                            ${text.escape(category.getDisplayName())}
                            <button class="btn btn-xs btn-danger delete pull-right" style="display: none;">
                                <i class="fa fa-inverse fa-close"></i>
                            </button>
                        </div>
                        <ul class="subcategories sortable">
                            <%-- Recursive Subcatgegories --%>
                            <c:set scope="request" var="thisCat" value="${category}"/>
                            <c:import url="${bundle.path}/partials/categories/subCategoryLi.jsp" charEncoding="UTF-8" />
                        </ul>
                    </li>
                </c:forEach>
                </ul>
            </div>
        </div>
    </div>
    <div class="col-sm-4">
        <form>
            <div class="panel-group" id="accordion">
                <div class="panel panel-default" heading="Add Category" id="panel-add-cat">
                    <div class="panel-heading">
                        <div class="panel-title add-category">
                            Add Category
                        </div>
                        <div class="" id="add-category">
                            <div class="panel-body">
                                <div>
                                    <div class="form-group add-root"> 
                                        <div class="form-group">
                                            <input type='hidden' id='parent-name'>
                                            <label for="category-name" class="control-label">Category Name/Slug</label>
                                            <input name="category-name" placeholder="Category Name" id="category-name" class="form-control"> 
                                            <label for="display-name" class="control-label">Display Name</label>
                                            <input placeholder="Display Name" id="display-name"  class="form-control"> 
                                            <button class="btn btn-success btn-sm add-category">Add Category</button>
                                        </div>
                                    </div> 
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="panel panel-default" heading="Edit Category" id="panel-edit-cat" style="display: none;">
                    <div class="panel-heading">
                        <div class="panel-title">
                            Edit Category
                        </div>
                        <div class="panel-collapse collapse" id="edit-category">
                            <div class="panel-body">
                                <div>
                                    <div class="form-group add-root"> 
                                        <div class="form-group">
                                            <label for="category-name" class="control-label">Category Name/Slug</label>
                                            <input name="category-name" placeholder="Category Name" id="change-name" class="form-control"> 
                                            <label for="display-name" class="control-label">Display Name</label>
                                            <input placeholder="Display Name" id="change-display"  class="form-control"> 
                                            <button class="btn btn-success btn-sm edit-category">Save</button>
                                        </div>
                                    </div> 
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </form>
    </div>
    <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
    <!-- Includes right sidebar. Remove if not needed. -->

</bundle:layout>