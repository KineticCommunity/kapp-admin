<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<%@include file="../../bundle/router.jspf" %>

<c:set var="console" value="${form}" scope="request"/>
<c:set var="currentSpace" value="${space}" scope="request"/>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <!-- Sets title and imports js and css specific to this console. -->
    <bundle:variable name="head">
        <c:import url="${bundle.path}/partials/management/head.jsp" charEncoding="UTF-8"/>
    </bundle:variable>

    
    <!-- BREADCRUMBS START HERE. Remove if not needed. ------------------------------------------->
    <bundle:variable name="breadcrumb">
        <li class="active">Management</li>
    </bundle:variable>
    <!-- BREADCRUMBS END HERE. ------------------------------------------------------------------->

    <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
    
    <div class="page-header">
        <div class="row">
            <div class="col-xs-12">
                <h3>
                    <span>${text.escape(currentSpace.name)}</span>
                    <small>Space</small>
                    <div class="pull-right users-table-buttons">
                        <c:if test="${identity.spaceAdmin}">
                            <a class="btn btn-tertiary" href="${bundle.kappLocation}/${console.slug}?page=management/config/space">
                                <span class="fa fa-cog fa-fw"></span> Space Configuration
                            </a>
                        </c:if>
                    </div>
                </h3>
            </div>
        </div>
    </div>
    
    <div class="row">
        <div class="col-xs-12">
            <table class="table table-sm table-hover table-striped form-management-kapps" 
                   data-table-kapps-list> 
                <thead>
                    <tr>
                        <th>Kapp</th>
                        <th>Updated</th>
                        <th data-orderable="false"></th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="currentKapp" items="${space.kapps}">
                        <c:if test="${kapp.slug != currentKapp.slug}">
                            <tr>
                                <td>
                                    <a href="${bundle.kappLocation}/${console.slug}?page=management/kapp&kapp=${currentKapp.slug}">
                                        ${text.escape(currentKapp.name)}
                                    </a>
                                </td>
                                <td data-order="${currentKapp.updatedAt}">
                                    <span data-moment-ago="${currentKapp.updatedAt}" data-toggle="tooltip"></span>
                                </td>
                                <td class="text-right">
                                    <a class="btn btn-xs btn-tertiary"
                                       href="${bundle.kappLocation}/${console.slug}?page=management/config/kapp&kapp=${currentKapp.slug}">
                                        <span class="fa fa-cog fa-fw"></span>
                                    </a>
                                </td>
                            </tr>
                        </c:if>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
    
</bundle:layout>