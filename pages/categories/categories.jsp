<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<c:set var="currentKapp" value="${space.getKapp(param.kapp)}" scope="request"/>

<!-- Show page content only if selected Kapp exists. -->
<c:choose>
    <c:when test="${empty currentKapp}">
        <script>window.location.replace("${bundle.kappLocation}/${form.slug}");</script>
    </c:when>
    <c:otherwise>
    
        <bundle:layout page="${bundle.path}/layouts/layout.jsp">
            <!-- Imports js and css specific to this console. -->
            <bundle:variable name="head">
                <c:import url="${bundle.path}/partials/categories/head.jsp" charEncoding="UTF-8"/>
            </bundle:variable>
            
            <!-- BREADCRUMBS START HERE. Remove if not needed. ------------------------------------------->
            <bundle:variable name="breadcrumb">
                <li><a href="${bundle.kappLocation}/${form.slug}">${form.name}</a></li>
                <li class="active">${text.escape(currentKapp.name)}</li>
            </bundle:variable>
            <!-- BREADCRUMBS END HERE. ------------------------------------------------------------------->

            <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
            
            <div class="page-header">
                <div class="row">
                    <div class="col-xs-12">
                        <h3>
                            <span>${text.escape(currentKapp.name)}</span>
                            <small>Categories</small>
                            <div class="pull-right">
                                <button class="btn btn-primary pull-right add-category btn-sm">
                                    <span class="fa fa-plus-circle"></span> Add Category
                                </button>
                            </div>
                        </h3>
                    </div>
                </div>
            </div>
            
            <div class="manage-categories col-sm-8" data-slug="${currentKapp.slug}">            
                <div class="workarea content-view-wrapper">
                    <div class="pages-panel">
                        <%-- For each of the categories --%>
                        <ul class="sortable top">
                            <div class="table no-data text-center">
                                <h4>There are no categories.</h4>
                                <a href="javascript:void(0)" class="add-category"><span class="fa fa-plus fa-fw"></span>Add a new Category</a>
                            </div>
        
                            <c:forEach var="category" items="${CategoryHelper.getCategories(currentKapp)}">
                                <li data-id="${category.getSlug()}" data-display="${category.getName()}">
                                    <div class="category">
                                        ${text.escape(category.getName())}
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
                        <div class="panel panel-default" heading="Edit Category" id="panel-edit-cat" style="display: none;">
                            <div class="panel-heading">
                                <div class="panel-title">
                                    Edit Category
                                </div>
                            </div>
                            <div class="panel-collapse collapse" id="edit-category">
                                <div class="panel-body">
                                    <div>
                                        <div class="form-group add-root"> 
                                            <div class="form-group">
                                                <label for="display-name" class="control-label">Category Name</label>
                                                <input placeholder="Display Name" id="change-display"  class="form-control"> 
                                                <label for="category-name" class="control-label">Category Slug</label>
                                                <input name="category-name" placeholder="Category Name" id="change-name" class="form-control"> 
                                                <button class="btn btn-success btn-sm edit-category">Save</button>
                                                <button class="btn btn-primary add-subcategory btn-sm pull-right"><span class="fa fa-plus-circle"></span> Add Subcategory</button>
                                            </div>
                                        </div> 
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="panel panel-default" heading="Add Category" id="panel-add-cat"  style="display: none;">
                            <div class="panel-heading">
                                <div class="panel-title add-category">
                                    Add Category
                                </div>
                            </div>
                            <div class="panel-collapse collapse" id="add-category">
                                <div class="panel-body">
                                    <div>
                                        <div class="form-group add-root"> 
                                            <div class="form-group">
                                                <input type='hidden' id='parent-name'>
                                                <label for="display-name" class="control-label">Category Name</label>
                                                <input placeholder="Display Name" id="display-name"  class="form-control"> 
                                                <label for="category-name" class="control-label">Category Slug</label>
                                                <input name="category-name" placeholder="Category Name" id="category-name" class="form-control"> 
                                                <button class="btn btn-success btn-sm add-category">Save</button>
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
            
        </bundle:layout>
        
    </c:otherwise>
</c:choose>