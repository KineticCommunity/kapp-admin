<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../../../bundle/initialization.jspf" %>

<c:set var="currentKapp" value="${space.getKapp(param.kapp)}" />

<button class="btn btn-tertiary pull-right add-category-init">
    <span class="fa fa-plus"></span> Add Category
</button>
<div class="row m-t-1">
    <div class="manage-categories col-sm-8" data-slug="${currentKapp.slug}">            
        <div class="workarea content-view-wrapper">
            <div class="pages-panel">
                <%-- For each of the categories --%>
                <ul class="sortable top">
                    <div class="table no-data text-center">
                        <h4>There are no categories.</h4>
                        <a href="javascript:void(0)" class="add-category-init"><span class="fa fa-plus fa-fw"></span>Add a new Category</a>
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
                                <c:import url="${bundle.path}/partials/management/config/kapp/subCategory.jsp" charEncoding="UTF-8" />
                            </ul>
                        </li>
                    </c:forEach>
                </ul>
            </div>
        </div>
    </div>
    <div class="col-sm-4">
        <form class="m-t-1">
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
                                        <input name="category-name" placeholder="Category Name" id="change-name" class="form-control m-b-2"> 
                                        <button class="btn btn-success edit-category pull-right">Save</button>
                                        <button class="btn btn-tertiary add-subcategory"><span class="fa fa-plus"></span> Add Subcategory</button>
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
                                <div class="add-root"> 
                                    <input type='hidden' id='parent-name'>
                                    <label for="display-name" class="field-label required">Category Name</label>
                                    <input type="text" id="display-name" class="form-control"> 
                                    <label for="category-name" class="field-label required">Category Slug</label>
                                    <input type="text" name="category-name" id="category-name" class="form-control m-b-2"> 
                                    <button class="btn btn-success add-category pull-right">Save</button>
                                </div> 
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </form>
    </div>
</div>
