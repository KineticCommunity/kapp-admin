<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <!-- Sets title and imports js and css specific to this console. -->
    <bundle:variable name="head">
        <c:import url="${bundle.path}/partials/${form.slug}/head.jsp" charEncoding="UTF-8"/>
    </bundle:variable>

    <c:set var="currentKapp" value="${space.getKapp(param.kapp)}" scope="request" />
    <c:set var="currentStore" value="${kapp.getForm(param.store)}" scope="request" />

    <!-- Show page content only if Kapp exists. Otherwise redirect to home page. -->
    <c:choose>
        <c:when test="${empty currentKapp}">
            <c:redirect url="${bundle.kappPath}"/>
        </c:when>
        <c:when test="${!identity.spaceAdmin}">
            <c:import url="${bundle.path}/partials/${form.slug}/adminError.jsp" charEncoding="UTF-8"/>
        </c:when>
        <c:otherwise>
            
            <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
            
            <ol class="breadcrumb">
                <li><a href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}">${form.name}</a></li>
                <li class="active ng-binding">${empty currentStore ? 'New Datastore' : currentStore.name}</li>
            </ol>
            
            <div class="page-header">
                <h3>
                    ${not empty currentStore ? currentStore.name : 'New Datastore'}  
                    <c:if test="${not empty currentStore}">
                        <small> Configuration</small>
                        <div class="pull-right">
                            <a class="btn btn-sm btn-default" href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=datastore/store&store=${currentStore.slug}">
                                <span class="fa fa-database fa-fw"></span>Records
                            </a>
                            <a class="btn btn-sm btn-primary" href="${bundle.spaceLocation}/app/#/${kapp.slug}/author/form/${currentStore.slug}/builder" target="_blank">
                                <span class="fa fa-mouse-pointer fa-fw"></span>Builder
                            </a>
                            <a class="btn btn-sm btn-primary" href="javascript:location.reload(true);">
                                <span class="fa fa-refresh fa-fw"></span>
                            </a>
                        </div>
                    </c:if>
                </h3>
            </div>
            
            <form id="${empty param.store ? 'create_datastore_form' : 'update_datastore_form'}" action="javascript:void(0);">
                <fieldset>
                    <div class="row">
                        <div class="col-xs-6">
                            <div class="form-group">
                                <label for="datastore_name" class="control-label">
                                    <abbr title="Required">*</abbr> Name
                                </label>
                                <input id="datastore_name" placeholder="Datastore Title" name="name" class="form-control" value="${currentStore.name}">
                            </div> 
                        </div>
                        <div class="col-xs-6">
                            <div class="form-group">
                                <label for="datastore_slug" class="control-label">
                                    <abbr title="Required">*</abbr> Slug
                                </label>
                                <input id="datastore_slug" placeholder="Datastore Slug" name="slug" class="form-control" value="${currentStore.slug}">
                            </div> 
                        </div>
                    </div> 
                    <div class="row">
                        <div class="col-xs-12">
                            <div class="form-group">
                                <label for="datastore_description" class="control-label text optional">Description</label>
                                <small> (optional)</small>
                                <textarea id="datastore_description" cols="40" rows="4" maxlength="4000" name="description" placeholder="Description of Datastore" class="form-control">${currentStore.description}</textarea>
                            </div>
                        </div>
                    </div>
                </fieldset>
                
                <c:if test="${not empty currentStore}">
                    <label for="column-table" class="text">Display Table Options</label> <small>(drag to order)</small>
                    <table class="table table-hover" id="column-table"> 
                        <thead>
                            <tr>
                                <th style="width:40%;">Field Name</th>
                                <th style="width:15%;">Visible</th>
                                <th style="width:15%;">Searchable</th>
                                <th style="width:15%;">Sortable</th>
                                <th style="width:15%;">Unique</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="column" items="${AdminHelper.getDatastoreColumns(currentStore)}">
                                <tr>
                                    <td class="column-name">${column.data}</td>
                                    <td class="column-visible"><input type="checkbox" ${column.visible ? 'checked' : ''}/></td>
                                    <td class="column-searchable"><input type="checkbox" ${column.searchable ? 'checked' : ''}/></td>
                                    <td class="column-orderable"><input type="checkbox" ${column.orderable ? 'checked' : ''}/></td>
                                    <td class="column-unique"><input type="checkbox" ${column.unique ? 'checked' : ''}/></td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:if>
                
                <div class="row">
                    <div class="col-xs-12">
                        <div class="form-buttons pull-right">
                            <button type="button" class="btn btn-success" id="${empty param.store ? 'create_datastore' : 'update_datastore'}" data-datastore-slug="${currentStore.slug}" data-console-slug="${form.slug}">
                                <span class="fa fa-check fa-fw"></span>${empty param.store ? 'Create' : 'Save'}
                            </button>
                            <a class="btn btn-link" href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}">Cancel</a>
                        </div>
                    </div>
                </div>
            </form>
        
            <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
    
            <!-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -------------------------------->
            <bundle:variable name="aside">
                <h3>${currentStore.name}</h3>
                <p>
                    ${currentStore.description}
                </p>
            </bundle:variable>
            <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
            
        </c:otherwise>
    </c:choose>
</bundle:layout>