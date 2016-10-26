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
            </bundle:variable>
            
            <!-- BREADCRUMBS START HERE. Remove if not needed. ------------------------------------------->
            <bundle:variable name="breadcrumb">
                <li><a href="${bundle.kappLocation}/${form.slug}">${form.name}</a></li>
                <li class="active">${currentStore.name}</li>
            </bundle:variable>
            <!-- BREADCRUMBS END HERE. ------------------------------------------------------------------->
            
            <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
            
            <div class="page-header">
                <h3>
                    ${currentStore.name} <small> Records</small>
                    <div class="pull-right datastore-records-table-buttons">
                        <a class="btn btn-sm btn-tertiary" href="${bundle.kappLocation}/${form.slug}?page=datastore/record&store=${currentStore.slug}">
                            <span class="fa fa-plus fa-fw"></span> Add Record
                        </a>
                        <input class="hide" accept=".csv" id="datastore-records-import" type="file">
                    </div>
                </h3>
            </div>
        
            <div class="row">
                <div class="col-xs-12">
                    
                    <table style="width:100%" class="table table-hover table-striped dt-responsive nowrap" id="datastore-records-table" 
                            data-datastore-name="${currentStore.name}" data-datastore-slug="${currentStore.slug}" 
                            data-console-slug="${form.slug}" data-kapp-slug="${kapp.slug}">
                        <tr>
                            <td class="alert alert-info">
                                <span class="fa fa-spinner fa-spin"></span>
                                Loading
                            </td>
                        </tr>
                    </table>
                    
                </div>
            </div>
        
            <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
    
            <!-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -------------------------------->
            <bundle:variable name="aside">
                <h3>${form.name}</h3>
                <h4>${currentStore.name}</h4>
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