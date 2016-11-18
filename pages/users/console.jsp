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
        <h3>
            ${form.name}
            <div class="pull-right users-table-buttons">
                <a class="btn btn-sm btn-tertiary" href="${bundle.kappLocation}/${form.slug}?page=users/user">
                    <span class="fa fa-plus fa-fw"></span> Add User
                </a>
                <input class="hide" accept=".csv" id="users-import" type="file">
            </div>
        </h3>
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

    <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
    
    <!-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -------------------------------->
    <bundle:variable name="aside">
        <h3>${form.name}</h3>
        <p>${form.description}</p>
    </bundle:variable>
    <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
    
</bundle:layout>