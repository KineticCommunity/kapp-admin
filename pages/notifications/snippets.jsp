<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<c:set var="notificationType" value="${not empty param.type? param.type : 'Template'}s"/>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <!-- Sets title and imports js and css specific to this console. -->
    <bundle:variable name="head">
        <c:import url="${bundle.path}/partials/notifications/head.jsp" charEncoding="UTF-8"/>
        <script>
            bundle.notifications.type = "Snippet";
        </script>
    </bundle:variable>

    <!-- BREADCRUMBS START HERE. Remove if not needed. ------------------------------------------->
    <bundle:variable name="breadcrumb">
        <li class="active">${form.name}</li>
    </bundle:variable>
    <!-- BREADCRUMBS END HERE. ------------------------------------------------------------------->

    <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->

    <div class="page-header">
        <h2>Notification <small> ${notificationType}</small>
            <div class="pull-right notification-table-buttons">
                <a class="btn btn-tertiary" href="${bundle.kappLocation}/${form.slug}?page=notifications/record&type=Snippet">
                    <span class="fa fa-plus fa-fw"></span> Add Snippet
                </a> 
                <input class="hide" accept=".csv" data-type="Snippet" id="notification-import" type="file">
            </div>
        </h2>
    </div>
    
    <div>
        <ul class="nav nav-tabs h4 stacked-xs" role="tablist" id="form-configuration-tabs">
            <li role="presentation"><a href="${bundle.kappLocation}/${form.slug}?type=Template">Templates</a></li>
            <li role="presentation" class="active"><a href="javascript:void(0);">Snippets</a></li>
        </ul>
        <div class="m-t-2">
            <table id="table-notifications" style="width:100%" class="table table-hover dt-responsive nowrap" 
                   data-console-slug="${form.slug}" 
                   data-kapp-slug="${kapp.slug}" 
                   data-datastore-slug="notification-data" 
                   id="table-notifications" 
                   data-type="Snippet" 
                   data-query="values[Type]=Snippet">
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
        <h5>${notificationType}</h5>
        <p>${form.description}</p>
        <hr class="border-color-white" />
        <p>To add a new snippet, click the <b class="nowrap"><span class="fa fa-plus"></span> Add Template</b> button.</p>
        <p>To edit a snippet, click the edit <b><span class="fa fa-pencil"></span></b> button.</p>
        <p>To clone a snippet, click the clone <b><span class="fa fa-clone"></span></b> button.</p>
        <p>To delete a record, click the delete <b><span class="fa fa-times"></span></b> button.</p>
        <p>To export snippets to a CSV file, click the <b>Export CSV</b> button.</p>
        <p>To import snippets from a CSV file, click the <b>Import CSV</b> button and select the file you want to import.</p>
        <div class="p-l-2">
            <p>
                The CSV file you import must have columns with headings corresponding to existing field names. 
                It may also have an <i>"ID"</i> column, used to update existing records.
            </p>
        </div>
        <p><b>
            <span class="fa fa-exclamation-circle"></span> Importing snippet records does not perform the form validations, 
            which may allow for invalid data to be saved. Please be careful so you do not destroy your data. 
        </b></p>
    </bundle:variable>
    <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
</bundle:layout>