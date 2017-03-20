<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<c:set var="currentStore" value="${kapp.getForm(param.store)}" scope="request" />

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <!-- Sets title and imports js and css specific to this console. -->
    <bundle:variable name="head">
        <c:import url="${bundle.path}/partials/datastore/head.jsp" charEncoding="UTF-8"/>
    </bundle:variable>
    
    <!-- BREADCRUMBS START HERE. Remove if not needed. ------------------------------------------->
    <bundle:variable name="breadcrumb">
        <li><a href="${bundle.kappLocation}/${form.slug}">${form.name}</a></li>
        <li class="active">${empty currentStore ? 'New Datastore' : currentStore.name}</li>
    </bundle:variable>
    <!-- BREADCRUMBS END HERE. ------------------------------------------------------------------->

    <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
    
    <div class="page-header">
        <h3>
            ${not empty currentStore ? currentStore.name : 'New Datastore'}  
            <c:if test="${not empty currentStore}">
                <small> Configuration</small>
                <div class="pull-right">
                    <a class="btn btn-sm btn-default" href="${bundle.kappLocation}/${form.slug}?page=datastore/store&store=${currentStore.slug}">
                        <span class="fa fa-database fa-fw"></span>Records
                    </a>
                    <a class="btn btn-sm btn-tertiary" href="${bundle.spaceLocation}/app/#/${kapp.slug}/author/form/${currentStore.slug}/builder" target="_blank">
                        <span class="fa fa-mouse-pointer fa-fw"></span>Builder
                    </a>
                    <a class="btn btn-sm btn-tertiary" href="javascript:location.reload(true);">
                        <span class="fa fa-refresh fa-fw"></span>
                    </a>
                </div>
            </c:if>
        </h3>
    </div>
    
    <form id="${empty currentStore ? 'create-datastore-form' : 'update-datastore-form'}" action="javascript:void(0);">
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
            <label for="column-table" class="text">Display Table Options <small class="hidden-xs">(drag to order)</small></label> 
            <div class="overflow-auto">
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
            </div>
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
                        <select id="datastore-bridge" class="form-control" data-bridge-name="${bridgeName}" 
                                data-model-exists="${not empty bridgeModel}" data-model-current-name="${bridgeModelName}">
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
            <label for="qualification-table" class="text">Bridge Qualifications</label> <small>(Model & Mapping Name: <b>${bridgeModelName}</b>)</small>
            <div class="overflow-auto">
                <table class="table table-hover" id="qualification-table">
                    <thead>
                        <tr>
                            <th style="width:46%;">Qualification</th>
                            <th style="width:18%;">Result Type</th>
                            <th style="width:22%;">Parameters</th>
                            <th style="width:14%;min-width:75px;"></th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="qualification" items="${bridgeModel.qualifications}">
                            <tr class="qualification-row">
                                <td class="qual-name">${qualification.name}</td>
                                <td class="qual-result-type">${qualification.resultType}</td>
                                <td class="qual-params">
                                    <c:set var="parameterMap" 
                                           value="${AdminHelper.getQualificationParameterMapWithValues(qualification.parameters, 
                                                                                                       bridgeMapping.getQualificationMapping(qualification.name).query)}" />
                                    <a class="qualification-modal-link" href="javascript:void(0);">Parameters (<span class="param-count">${fn:length(parameterMap)}</span>)</a>
                                    <div class="modal-params hide">
                                        <table class="table table-hover" id="params-table"> 
                                            <thead>
                                                <tr>
                                                    <th>Name</th>
                                                    <th>Value*</th>
                                                    <th></th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="parameter" items="${parameterMap}">
                                                    <tr>
                                                        <td class="param-name" data-param-name="${parameter.key}">${parameter.key}</td>
                                                        <td class="param-value">
                                                            <input class="input-sm form-control" placeholder="Optional" value="${text.escape(parameter.value)}"/>
                                                        </td>
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
                                                            <c:if test="${text.equals(qualification.resultType, 'Single')}">
                                                                <option value="Submission ID">Submission ID</option>
                                                            </c:if>
                                                            <c:forEach var="field" items="${currentStore.pages[0].fields}">
                                                                <option value="${field.name}">${field.name}</option>
                                                            </c:forEach>
                                                        </select>
                                                    </td>
                                                    <td class="param-add-btn"><button class="btn btn-sm btn-success pull-right"><span class="fa fa-plus"></span> Add Parameter</button></td>
                                                </tr>
                                            </tbody>
                                            <tfoot>
                                                <tr>
                                                    <td colspan="2" class="disclaimer">
                                                        *If a value is entered, the value will be used directly in the query instead of becoming a parameter for the bridged resource.
                                                    </td>
                                                </tr>
                                            </tfoot>
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
            </div>
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
                    <button type="button" class="btn btn-success" id="${empty currentStore ? 'create-datastore' : 'update-datastore'}" data-datastore-slug="${currentStore.slug}" data-console-slug="${form.slug}">
                        <span class="fa fa-check fa-fw"></span>${empty currentStore ? 'Create' : 'Save'}
                    </button>
                    <a class="btn btn-link" href="${bundle.kappLocation}/${form.slug}">Cancel</a>
                </div>
            </div>
        </div>
    </form>
    
    <!-- Hidden template code used by JavaScript. -->
    <div class="hidden-qual-params-template hide">
        <a class="qualification-modal-link" href="javascript:void(0);">Parameters (<span class="param-count"></span>)</a>
        <div class="modal-params hide">
            <table class="table table-hover" id="params-table"> 
                <thead><tr><th>Name</th><th>Value*</th><th></th></tr></thead>
                <tbody></tbody>
            </table>
            <table class="table"> 
                <tbody>
                    <tr>
                        <td class="param-add-value">
                            <select class="input-sm form-control">
                                <option value="Submission ID">Submission ID</option>
                                <c:forEach var="field" items="${currentStore.pages[0].fields}">
                                    <option value="${field.name}">${field.name}</option>
                                </c:forEach>
                            </select>
                        </td>
                        <td class="param-add-btn"><button class="btn btn-sm btn-success pull-right"><span class="fa fa-plus"></span> Add Parameter</button></td>
                    </tr>
                </tbody>
                <tfoot>
                    <tr>
                        <td colspan="2" class="disclaimer">
                            *If a value is entered, the value will be used directly in the query instead of becoming a parameter for the bridged resource.
                        </td>
                    </tr>
                </tfoot>
            </table>
        </div>
    </div>
    <div class="hidden-qual-params-row-template hide">
        <table>
            <tbody>
                <tr>
                    <td class="param-name" data-param-name="{{parameterName}}">{{parameterName}}</td>
                    <td class="param-value">
                        <input class="input-sm form-control" placeholder="Optional" value="{{parameterValue}}"/>
                    </td>
                    <td class="param-actions">
                        <div class="btn-group pull-right">
                            <button type="button" class="btn btn-xs btn-danger param-delete">
                                <span class="fa fa-times fa-fw"></span>
                            </button>
                        </div>
                    </td>
                </tr>
            </tbody>
        </table>
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
        <h3>${form.name}</h3>
        <h4>${not empty currentStore ? currentStore.name : 'New Datastore'}</h4>
        <p>${currentStore.description}</p>
        <hr class="border-color-white" />
        <c:choose>
            <c:when test="${empty currentStore}">
                <p>Creating a new Datastore will create a new Kinetic Request form to be used for storing data.</p>
                <p>
                    <b>Bridge Name</b>: Select the Kinetic Core bridge to allow for automatic bridge creation for this datastore 
                    (The Kinetic Core Bridge Adapter must first be installed into Bridgehub to allow this data to be retrieved via bridges).
                </p>
            </c:when>
            <c:otherwise>
                <p>
                    To update the datastore form fields, click the <b class="nowrap"><span class="fa fa-mouse-pointer"></span> Builder</b> button, 
                    which will open the form builder in a new window. You will need to reload this page after making changes in the form builder, 
                    which can be done by clicking the reload <span class="fa fa-refresh"></span> button.
                </p>
                <p><b><span class="fa fa-exclamation-circle"></span> Datastore forms cannot contain more than 1 page.</b></p>
                <p>
                    To view, add, or edit the data stored in this datastore, 
                    click the <b class="nowrap"><span class="fa fa-database"></span> Records</b> button.
                </p>
                <hr class="border-color-white" />
                <p>
                    The <b>Display Table Options</b> section lists all of the fields that exist in this datastore. 
                    The order in this table will determine the order the records appear in the Records table. 
                    You may order the table by dragging the rows.
                    <div class="p-l-2">
                        <div><b>Visible</b>: Should this field appear in the records table?</div>
                        <div><b>Searchable</b>: Should the data in this field be searchable in the records table?</div>
                        <div><b>Sortable</b>: Should the records table be sortable by this field?</div>
                        <div><b>Unique</b>: Should the data in this field be required to be unique for all records?</div>
                    </div>
                </p>
                <c:choose>
                    <c:when test="${empty bridgeName}">
                        <p>
                            <b>Bridge Name</b>: Select the Kinetic Core bridge to allow for automatic bridge creation for this datastore 
                            (The Kinetic Core Bridge Adapter must first be installed into Bridgehub to allow this data to be retrieved via bridges).
                        </p>
                    </c:when>
                    <c:otherwise>
                        <p><b>Bridge Name</b>: The Kinetic Core bridge, which allows for automatic bridge creation for this datastore.</p>
                        <p><b>Bridge Qualifications</b>: List of existing qualifications used to retrieve the data from this datastore.</p>
                    </c:otherwise>
                </c:choose>
            </c:otherwise>
        </c:choose>
    </bundle:variable>
    <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
    
</bundle:layout>