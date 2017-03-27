<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<%@include file="../../bundle/router.jspf" %>

<%--bundle:request method="get"
                url="${bundle.apiPath}/users?include=attributes%2CprofileAttributes"
                var="userList"
                scope="request"></bundle:request --%>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <!-- Sets title and imports js and css specific to this console. -->
    <bundle:variable name="head">
        <c:import url="${bundle.path}/partials/users/head.jsp" charEncoding="UTF-8"/>
    </bundle:variable>
    
    <!-- BREADCRUMBS START HERE. Remove if not needed. ------------------------------------------->
    <bundle:variable name="breadcrumb">
        <li class="active">${form.name}</li>
    </bundle:variable>
    <!-- BREADCRUMBS END HERE. ------------------------------------------------------------------->

    <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->

    <div class="page-header">
        <h2>
            ${form.name}
            <div class="pull-right users-table-buttons">
                <a class="btn btn-tertiary" href="${bundle.kappLocation}/${form.slug}?page=users/user">
                    <span class="fa fa-plus fa-fw"></span> Create User
                </a>
                <input class="hide" accept=".csv" id="users-import" type="file">
            </div>
        </h2>
    </div>

    <div class="row">
        <div class="col-xs-12">
            <table width="100%" class="table table-hover table-striped dt-responsive" id="users-table"
                   data-user-list data-space-name="${space.name}" data-console-slug="${form.slug}"> 
                <thead class="nowrap"></thead>
                <tbody>
                    <tr>
                        <td class="text-center">
                            <span class="fa fa-spinner fa-spin"></span>
                            <span>Loading</span>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
    
    <div class="users-table-actions-template hide">
        <div class="btn-group pull-right" role="group">
            <button class="edit-user-btn btn btn-xs btn-default" type="button"><span class="fa fa-pencil fa-fw"></span></button>
            <button class="clone-user-btn btn btn-xs btn-success" type="button"><span class="fa fa-clone fa-fw"></span></button>
        </div>
    </div>

    <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
    
    <!-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -------------------------------->
    <bundle:variable name="aside">
        <h3>${form.name}</h3>
        <p>${form.description}</p>
        <hr class="border-color-white" />
        <p>To create a new user, click the <b class="nowrap"><span class="fa fa-plus"></span> Create User</b> button.</p>
        <p>To update a user, click the edit <b><span class="fa fa-pencil"></span></b> button.</p>
        <p>To export the list of users to a CSV file, click the <b>Export CSV</b> button.</p>
        <p>To create new users from a CSV file, click the <b>Import CSV</b> button and select the file you want to import.</p>
        <div class="p-l-2">
            <p>
                You may download a template for creating new users via import  
                <a class="download-import-template" href="javascript:void(0);"><span class="fa fa-download"></span> here</a>. 
                The template includes the required formatting for the <i>Enabled</i> and <i>Groups</i> columns.
            </p>
        </div>
    </bundle:variable>
    <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
    
</bundle:layout>