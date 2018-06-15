<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<%@include file="../../bundle/router.jspf" %>

<c:set var="console" value="${form}" scope="request"/>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <!-- Sets title and imports js and css specific to this console. -->
    <bundle:variable name="pageTitle">${text.escape(i18n.translate(space.name))} Utilities</bundle:variable>
    <bundle:variable name="head">
        <c:import url="${bundle.path}/partials/utilities/head.jsp" charEncoding="UTF-8"/>
    </bundle:variable>

    
    <!-- BREADCRUMBS START HERE. Remove if not needed. ------------------------------------------->
    <bundle:variable name="breadcrumb">
        <li class="active">Utilities</li>
    </bundle:variable>
    <!-- BREADCRUMBS END HERE. ------------------------------------------------------------------->

    <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
    
    <div class="page-header">
        <h2>
            <span>${text.escape(space.name)}</span>
            <small>Utilities</small>
            <div class="pull-right">
                <c:if test="${identity.spaceAdmin}">
                    <!-- <a class="btn btn-tertiary" href="${bundle.kappLocation}/${console.slug}?page=management/config/space">
                        <span class="fa fa-cog fa-fw"></span> Add Utility Form
                    </a> -->
                </c:if>
            </div>
        </h2>
    </div>
    
    <div class="row">
        <div class="col-xs-12">
            <h4 class="m-t-4">Forms</h4>
            <table class="table table-sm table-hover management-kapps-table" 
                   data-table-dom> 
                <thead>
                    <tr>
                        <th>Form Name</th>
                        <th>Form Description</th>
                        <th>Updated</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="currentForm" items="${kapp.getFormsByType('Utility')}">
                            <tr>
                                <td>
                                    <a href="${bundle.kappLocation}/${currentForm.slug}">
                                        ${text.escape(currentForm.name)}
                                    </a>
                                </td>
                                <td>
                                    ${text.escape(currentForm.description)}
                                </td>
                                <td data-order="${currentForm.updatedAt}">
                                    <span data-moment-ago="${currentForm.updatedAt}" data-toggle="tooltip"></span>
                                    by <a href="${empty bundle.spaceLocation ? '/' : bundle.spaceLocation}?page=profile&username=${text.escapeUrlParameter(currentForm.updatedBy)}">${currentKapp.updatedBy}</a>
                                </td>
                            </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
    
</bundle:layout>