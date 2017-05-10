<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<%@include file="../../bundle/router.jspf" %>

<c:set var="console" value="${form}" scope="request"/>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <!-- Sets title and imports js and css specific to this console. -->
    <bundle:variable name="pageTitle">${text.escape(i18n.translate(space.name))} Management</bundle:variable>
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
        <h2>
            <span>${text.escape(space.name)}</span>
            <small>Space Management</small>
            <div class="pull-right">
                <c:if test="${identity.spaceAdmin}">
                    <a class="btn btn-tertiary" href="${bundle.kappLocation}/${console.slug}?page=management/config/space">
                        <span class="fa fa-cog fa-fw"></span> Configure Space
                    </a>
                </c:if>
            </div>
        </h2>
    </div>
    
    <div class="row">
        <div class="col-xs-12 m-b-2">
            <label>Updated</label>
            <span data-moment-ago="${space.updatedAt}" data-toggle="tooltip"></span>
            by <a href="${bundle.spaceLocation}?page=profile&username=${text.escapeUrlParameter(space.updatedBy)}">${space.updatedBy}</a>
        </div>
        <div class="col-xs-12">
            <h4 class="m-t-4">Kapps</h4>
            <table class="table table-sm table-hover management-kapps-table" 
                   data-table-dom> 
                <thead>
                    <tr>
                        <th>Kapp Name</th>
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
                                    by <a href="${bundle.spaceLocation}?page=profile&username=${text.escapeUrlParameter(currentKapp.updatedBy)}">${currentKapp.updatedBy}</a>
                                </td>
                                <td class="text-right">
                                    <c:if test="${identity.spaceAdmin || TeamsHelper.isKappOwner(identity.user, currentKapp)}">
                                        <a class="btn btn-xs btn-tertiary" title="Configure"
                                           href="${bundle.kappLocation}/${console.slug}?page=management/config/kapp&kapp=${currentKapp.slug}">
                                            <span class="fa fa-cog fa-fw"></span>
                                        </a>
                                    </c:if>
                                </td>
                            </tr>
                        </c:if>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
    
</bundle:layout>