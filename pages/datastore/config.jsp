<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<c:set var="currentKapp" value="${space.getKapp(param.kapp)}" scope="request" />
<c:set var="currentStore" value="${kapp.getForm(param.store)}" scope="request" />

<!-- Show page content only if Kapp & Store exist. Otherwise redirect to valid page. -->
<c:choose>
    <c:when test="${empty currentKapp}">
        <script>window.location.replace("${bundle.kappLocation}");</script>
    </c:when>
    <c:otherwise>
    
        <bundle:layout page="${bundle.path}/layouts/layout.jsp">
            <!-- Sets title and imports js and css specific to this console. -->
            <bundle:variable name="head">
                <c:import url="${bundle.path}/partials/datastore/head.jsp" charEncoding="UTF-8"/>
            </bundle:variable>

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
            
            <form id="${empty param.store ? 'create-datastore-form' : 'update-datastore-form'}" action="javascript:void(0);">
                <fieldset>
                    <div class="row">
                        <div class="col-xs-6">
                            <div class="form-group">
                                <label for="datastore-name" class="control-label">
                                    <abbr title="Required">*</abbr> Name
                                </label>
                                <input id="datastore-name" placeholder="Datastore Title" name="name" class="form-control" value="${currentStore.name}">
                            </div> 
                        </div>
                        <div class="col-xs-6">
                            <div class="form-group">
                                <label for="datastore-slug" class="control-label">
                                    <abbr title="Required">*</abbr> Slug
                                </label>
                                <input id="datastore-slug" placeholder="Datastore Slug" name="slug" class="form-control" value="${currentStore.slug}">
                            </div> 
                        </div>
                    </div> 
                    <div class="row">
                        <div class="col-xs-12">
                            <div class="form-group">
                                <label for="datastore-description" class="control-label text optional">Description</label>
                                <small> (optional)</small>
                                <textarea id="datastore-description" cols="40" rows="4" maxlength="4000" name="description" placeholder="Description of Datastore" class="form-control">${currentStore.description}</textarea>
                            </div>
                        </div>
                    </div>
                </fieldset>
                
                <c:if test="${not empty currentStore}">
                    <label for="column-table" class="text">Display Table Options</label> <small>(drag to order)</small>
                    <table class="table table-hover" id="column-table"> 
                        <thead>
                            <tr>
                                <th style="width:55%;">Field Name</th>
                                <th style="width:15%;">Visible</th>
                                <th style="width:15%;">Searchable</th>
                                <th style="width:15%;">Sortable</th>
                                <th style="width:15%;">Unique</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="column" items="${AdminHelper.getDatastoreColumns(currentStore, 'Datastore Configuration')}">
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
                
                <c:if test="${not empty currentStore}">
                    <c:set var="bridgeModelName" value="Datastore - ${currentStore.name}"/>
                    <c:set var="bridgeModel" value="${space.getBridgeModel(bridgeModelName)}"/>
                    <c:set var="bridgeMapping" value="${bridgeModel.getActiveMapping()}"/>
                    <c:set var="bridgeName" value="${bridgeMapping.getBridgeName()}"/>
                </c:if>
                
                <fieldset>
                    <div class="row">
                        <div class="col-xs-6">
                            <div class="form-group">
                                <label for="datastore-bridge" class="control-label">Bridge Name</label>
                                <select id="datastore-bridge" class="form-control" data-bridge-name="${bridgeName}" data-model-exists="${not empty bridgeModel}">
                                    <c:if test="${empty bridgeName || empty space.getBridge(bridgeName)}"><option/></c:if>
                                    <c:forEach var="bridge" items="${space.bridges}">
                                        <option value="${bridge.name}" ${bridgeName eq bridge.name ? 'selected' : ''}>${bridge.name}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <c:out value=""></c:out>
                        </div>
                    </div>
                </fieldset>
                
                <c:if test="${not empty currentStore && not empty bridgeName}">
                    <label for="column-table" class="text">Bridge Qualifications</label> <small>(Model & Mapping Name: <b>${bridgeModelName}</b>)</small>
                    <table class="table table-hover" id="qualification-table">
                        <thead>
                            <tr>
                                <th style="width:46%;">Qualification</th>
                                <th style="width:18%;">Result Type</th>
                                <th style="width:22%;">Parameters</th>
                                <th style="width:14%;"></th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="qualification" items="${bridgeModel.qualifications}">
                                <tr class="qualification-row">
                                    <td class="qual-name">${qualification.name}</td>
                                    <td class="qual-result-type">${qualification.resultType}</td>
                                    <td class="qual-params">
                                        <a class="qualification-modal-link" href="javascript:void(0);">Parameters (<span class="param-count">${fn:length(qualification.parameters)}</span>)</a>
                                        <div class="modal-params hide">
                                            <table class="table table-hover" id="params-table"> 
                                                <thead>
                                                    <tr>
                                                        <th>Name</th>
                                                        <th></th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:forEach var="parameter" items="${qualification.parameters}">
                                                        <tr>
                                                            <td class="param-name" data-param-name="${parameter.name}">${parameter.name}</td>
                                                            <td class="param-actions">
                                                                <div class="btn-group pull-right">
                                                                    <button type="button" class="btn btn-xs btn-danger param-delete">
                                                                        <span class="fa fa-times fa-fw"></span>
                                                                    </button>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </tbody>
                                            </table>
                                            <table class="table"> 
                                                <tbody>
                                                    <tr>
                                                        <td class="param-add-value">
                                                            <select class="input-sm form-control">
                                                                <c:forEach var="field" items="${currentStore.pages[0].fields}">
                                                                    <option value="${field.name}">${field.name}</option>
                                                                </c:forEach>
                                                            </select>
                                                        </td>
                                                        <td class="param-add-btn"><button class="btn btn-sm btn-success pull-right"><span class="fa fa-plus"></span> Add Parameter</button></td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </div>
                                    </td>
                                    <td class="qual-actions">
                                        <div class="btn-group pull-right qual-actions">
                                            <button type="button" class="btn btn-xs btn-default qual-edit">
                                                <span class="fa fa-pencil fa-fw"></span>
                                            </button>
                                            <button type="button" class="btn btn-xs btn-danger qual-delete">
                                                <span class="fa fa-times fa-fw"></span>
                                            </button>
                                        </div>
                                        <div class="btn-group pull-right qual-edit-actions hide">
                                            <button type="button" class="btn btn-xs btn-danger qual-cancel-edit">
                                                <span class="fa fa-times fa-fw"></span>
                                            </button>
                                            <button type="button" class="btn btn-xs btn-success qual-save-edit">
                                                <span class="fa fa-check fa-fw"></span>
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                    <table class="table" id="add-qualification-table"> 
                        <tbody>
                            <tr>
                                <td style="width:46%;" class="qual-add-name">
                                    <input class="input-sm form-control" placeholder="Qualification Name"/>
                                </td>
                                <td style="width:18%;" class="qual-add-result-type">
                                    <select class="input-sm form-control">
                                        <option value="Multiple">Multiple</option>
                                        <option value="Single">Single</option>
                                    </select>
                                </td>
                                <td style="width:36%;" class="qual-add-btn">
                                    <button class="btn btn-sm btn-success pull-right"><span class="fa fa-plus"></span> Add Qualification</button>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </c:if>
                
                <div class="row">
                    <div class="col-xs-12">
                        <div class="form-buttons pull-right">
                            <button type="button" class="btn btn-success" id="${empty param.store ? 'create-datastore' : 'update-datastore'}" data-datastore-slug="${currentStore.slug}" data-console-slug="${form.slug}">
                                <span class="fa fa-check fa-fw"></span>${empty param.store ? 'Create' : 'Save'}
                            </button>
                            <a class="btn btn-link" href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}">Cancel</a>
                        </div>
                    </div>
                </div>
            </form>
            
            <!-- Hidden template code used by JavaScript. -->
            <div class="hidden-qual-params-template hide">
                <a class="qualification-modal-link" href="javascript:void(0);">Parameters (<span class="param-count"></span>)</a>
                <div class="modal-params hide">
                    <table class="table table-hover" id="params-table"> 
                        <thead><tr><th>Name</th><th></th></tr></thead>
                        <tbody></tbody>
                    </table>
                    <table class="table"> 
                        <tbody>
                            <tr>
                                <td class="param-add-value">
                                    <select class="input-sm form-control">
                                        <c:forEach var="field" items="${currentStore.pages[0].fields}">
                                            <option value="${field.name}">${field.name}</option>
                                        </c:forEach>
                                    </select>
                                </td>
                                <td class="param-add-btn"><button class="btn btn-sm btn-success pull-right"><span class="fa fa-plus"></span> Add Parameter</button></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="hidden-qual-actions-template hide">
                <div class="btn-group pull-right qual-actions">
                    <button type="button" class="btn btn-xs btn-default qual-edit">
                        <span class="fa fa-pencil fa-fw"></span>
                    </button>
                    <button type="button" class="btn btn-xs btn-danger qual-delete">
                        <span class="fa fa-times fa-fw"></span>
                    </button>
                </div>
                <div class="btn-group pull-right qual-edit-actions hide">
                    <button type="button" class="btn btn-xs btn-danger qual-cancel-edit">
                        <span class="fa fa-times fa-fw"></span>
                    </button>
                    <button type="button" class="btn btn-xs btn-success qual-save-edit">
                        <span class="fa fa-check fa-fw"></span>
                    </button>
                </div>
            </div>
        
            <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
    
            <!-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -------------------------------->
            <bundle:variable name="aside">
                <h3>${not empty currentStore ? currentStore.name : 'New Datastore'}</h3>
                <p>
                    ${currentStore.description}
                </p>
                <hr />
                <p>
                    <span class="fa fa-exclamation-circle"></span> Datastore forms can not contain more than 1 page.
                </p>
            </bundle:variable>
            <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
            
        </bundle:layout>
        
    </c:otherwise>
</c:choose>