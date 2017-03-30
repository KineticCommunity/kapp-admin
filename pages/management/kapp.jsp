<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<c:set var="console" value="${form}" scope="request"/>
<c:set var="currentSpace" value="${space}" scope="request"/>
<c:set var="currentKapp" value="${space.getKapp(param.kapp)}" scope="request"/>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <!-- Sets title and imports js and css specific to this console. -->
    <bundle:variable name="head">
        <c:import url="${bundle.path}/partials/management/head.jsp" charEncoding="UTF-8"/>
    </bundle:variable>

    
    <!-- BREADCRUMBS START HERE. Remove if not needed. ------------------------------------------->
    <bundle:variable name="breadcrumb">
        <li><a href="${bundle.kappLocation}/${console.slug}">Management</a></li>
        <li class="active">${text.escape(currentKapp.name)}</li>
    </bundle:variable>
    <!-- BREADCRUMBS END HERE. ------------------------------------------------------------------->

    <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
    
    <div class="page-header">
        <div class="row">
            <div class="col-xs-12">
                <h3>
                    <span>${text.escape(currentKapp.name)}</span>
                    <small>Kapp</small>
                    <div class="pull-right users-table-buttons">
                        <a class="btn btn-tertiary" href="${bundle.kappLocation}/${console.slug}?page=management/config/kapp&kapp=${currentKapp.slug}">
                            <span class="fa fa-cog fa-fw"></span> Kapp Configuration
                        </a>
                    </div>
                </h3>
            </div>
        </div>
    </div>
    
    <div class="row">
        <div class="col-xs-12">
            <table class="table table-sm table-hover table-striped form-management-forms" 
                   data-table-forms-list> 
                <thead>
                    <tr>
                        <th>Form</th>
                        <th>Type</th>
                        <th>Updated</th>
                        <th>Status</th>
                        <c:forEach var="attributeDefinition" items="${currentKapp.formAttributeDefinitions}">
                            <th class="visibility-toggle" data-visible="false">
                                ${text.escape(attributeDefinition.name)}
                            </th>
                        </c:forEach>
                        <th data-orderable="false"></th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="currentForm" items="${currentKapp.forms}">
                        <tr>
                            <td>
                                <a href="${bundle.kappLocation}/${console.slug}?page=management/form&kapp=${currentKapp.slug}&form=${currentForm.slug}">
                                    ${text.escape(currentForm.name)}
                                </a>
                            </td>
                            <td>${text.escape(currentForm.type.name)}</td>
                            <td data-order="${currentForm.updatedAt}">
                                <span data-moment-ago="${currentForm.updatedAt}" data-toggle="tooltip"></span>
                            </td>
                            <td><span class="label ${AdminHelper.getFormStatusLabelClass(form)}">${currentForm.status}</span></td>
                            <c:forEach var="attributeDefinition" items="${currentKapp.formAttributeDefinitions}">
                                <td class="visibility-toggle">
                                    <c:choose>
                                        <c:when test="${attributeDefinition.allowsMultiple}">
                                            <c:forEach var="attributeValue" items="${currentForm.getAttributeValues(attributeDefinition.name)}">
                                                ${attributeValue} <br />
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            ${currentForm.getAttributeValue(attributeDefinition.name)}
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </c:forEach>
                            <td class="text-right">
                                <a class="btn btn-xs btn-tertiary"
                                   href="${bundle.kappLocation}/${console.slug}?page=management/config/form&kapp=${currentKapp.slug}&form=${currentForm.slug}">
                                    <span class="fa fa-cog fa-fw"></span>
                                </a>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
    
</bundle:layout>