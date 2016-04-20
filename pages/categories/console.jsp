<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <!-- Sets title and imports js and css specific to this console. -->
    <bundle:variable name="head">
        <title>Admin Console<c:if test="${not empty form}"> | ${form.name}</c:if></title>
        <c:import url="${bundle.path}/partials/${not empty form ? form.slug : ''}/head.jsp" charEncoding="UTF-8"/>
    </bundle:variable>

    <c:set var="currentKapp" value="${space.getKapp(param.kapp)}" scope="request"/>
    
    <!-- Show page content only if Kapp exists. Otherwise redirect to home page. -->
    <c:choose>
        <c:when test="${empty currentKapp}">
            <c:redirect url="${bundle.kappPath}"/>
        </c:when>
        <c:otherwise>
        
            <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
    
            <div class="page-header clearfix">
                <h3>${form.name} <button class="btn btn-primary pull-right add-category btn-sm"><span class="fa fa-plus-circle"></span> Add Category</button></h3>
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
            
        </c:otherwise>
    </c:choose>
</bundle:layout>