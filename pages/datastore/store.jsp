<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<c:set var="currentStore" value="${kapp.getForm(param.store)}" scope="request" />

<!-- Show page content only if Store exist. Otherwise redirect to Datastore home page. -->
<c:choose>
    <c:when test="${empty currentStore}">
        <script>window.location.replace("${bundle.kappLocation}/${form.slug}");</script>
    </c:when>
    <c:otherwise>

        <bundle:layout page="${bundle.path}/layouts/layout.jsp">
            <!-- Sets title and imports js and css specific to this console. -->
            <bundle:variable name="head">
                <c:import url="${bundle.path}/partials/datastore/head.jsp" charEncoding="UTF-8"/>
                <script>
                    bundle.adminDatastore.storeSlug = "${currentStore.slug}";
                    bundle.adminDatastore.storeName = "${currentStore.name}";
                </script>
            </bundle:variable>
            
            <!-- BREADCRUMBS START HERE. Remove if not needed. ------------------------------------------->
            <bundle:variable name="breadcrumb">
                <li><a href="${bundle.kappLocation}/${form.slug}">${form.name}</a></li>
                <li class="active">${currentStore.name}</li>
            </bundle:variable>
            <!-- BREADCRUMBS END HERE. ------------------------------------------------------------------->
            
            <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
            
            <div class="page-header">
                <h2>
                    <span>${currentStore.name}</span>
                    <small>Records</small>
                    <div class="pull-right datastore-records-table-buttons">
                        <a class="btn btn-tertiary" href="${bundle.kappLocation}/${form.slug}?page=datastore/record&store=${currentStore.slug}">
                            <span class="fa fa-plus fa-fw"></span> Add Record
                        </a>
                        <input class="hide" accept=".csv" id="datastore-records-import" type="file">
                    </div>
                </h2>
            </div>
        
            <div class="row">
                <div class="col-xs-12 large-volume-datastore hide">
                    <div class="alert alert-warning">
                        <h4>
                            <span class="fa fa-info-circle"></span>
                            <span>Large Volume Datastore</span>
                        </h4>
                        <p>
                            The ${currentStore.name} Datastore contains too many records to display at one time. 
                            Please enter search criteria to narrow down the results, 
                            or use the buttons below the table to navigate between chunks of 2000 records.
                        </p>
                    </div>
                </div>
                <div class="col-xs-12 large-volume-datastore hide">
                    <strong>Search Criteria</strong>
                </div>
                <div class="col-sm-6 large-volume-datastore hide" id="datastore-records-criteria-field">
                    <div class="input-group input-group-sm">
                        <span class="input-group-addon">Field</span>
                        <select class="form-control">
                            <option />
                            <c:forEach var="col" items="${AdminHelper.getDatastoreColumnsAlphabetically(currentStore, 'Datastore Configuration')}">
                                <option value="${col.data}" data-render-type="${col.renderType}">${col.data}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <div class="col-sm-6 large-volume-datastore hide" id="datastore-records-criteria-value">
                    <div class="input-group input-group-sm">
                        <span class="input-group-addon">Value</span>
                        <input type="text" class="form-control" placeholder="Exact and Case Sensitive">
                        <span class="input-group-btn">
                            <button class="btn btn-default search" type="button"><span class="fa fa-search"></span></button>
                        </span>
                    </div>
                </div>
                <div class="col-xs-12 large-volume-datastore hide m-b-4" id="datastore-records-criteria-display">
                    <span class="badge reset">Reset</span>
                </div>
                
                <div class="col-xs-12">
                    <table style="width:100%" class="table table-hover dt-responsive nowrap" 
                           id="datastore-records-table-${currentStore.slug}" data-datastore-records-table>
                        <tr>
                            <td class="alert alert-info">
                                <span class="fa fa-spinner fa-spin"></span>
                                Loading
                            </td>
                        </tr>
                    </table>
                </div>
                
                <div class="col-xs-12 large-volume-datastore hide m-t-2" id="datastore-records-chunk-pagination">
                    <div class="alert alert-warning clearfix text-center">
                        <p><strong class="chunk-info"></strong></p>
                        <div class="btn-group m-t-1" role="group">
                            <div class="btn-group" role="group">
                                <button class="btn btn-subtle previous-chunk" type="button">Previous 2000</button>
                            </div>
                            <div class="btn-group" role="group">
                                <button class="btn btn-subtle next-chunk" type="button">Next 2000</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        
            <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
    
            <!-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -------------------------------->
            <bundle:variable name="aside">
                <h3>${form.name}</h3>
                <h5>${currentStore.name}</h5>
                <p>${currentStore.description}</p>
                <hr class="border-color-white" />
                <p>To add a new record to this datastore, click the <b class="nowrap"><span class="fa fa-plus"></span> Add Record</b> button.</p>
                <p>To edit a record, click the edit <b><span class="fa fa-pencil"></span></b> button.</p>
                <p>To clone a record, click the clone <b><span class="fa fa-clone"></span></b> button.</p>
                <p>To delete a record, click the delete <b><span class="fa fa-times"></span></b> button.</p>
                <p>To export the records to a CSV file, click the <b>Export CSV</b> button.</p>
                <p>To import records from a CSV file, click the <b>Import CSV</b> button and select the file you want to import.</p>
                <div class="p-l-2">
                    <p>
                        The CSV file you import must have columns with headings corresponding to existing field names. 
                        It may also have a <i>"Datastore Record ID"</i> column, used to update existing records.
                    </p>
                </div>
                <p><b>
                    <span class="fa fa-exclamation-circle"></span> Importing datastore records does not perform the form validations, 
                    which may allow for invalid data to be saved. Please be careful so you do not destroy your data. 
                </b></p>
                
                
            </bundle:variable>
            <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
            
        </bundle:layout>
        
    </c:otherwise>
</c:choose>