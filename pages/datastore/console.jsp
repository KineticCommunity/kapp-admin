<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<%@include file="../../bundle/router.jspf" %>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <!-- Sets title and imports js and css specific to this console. -->
    <bundle:variable name="head">
        <c:import url="${bundle.path}/partials/datastore/head.jsp" charEncoding="UTF-8"/>
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
            <div class="pull-right">
                <a class="btn btn-sm btn-primary" href="${bundle.kappLocation}/${form.slug}?page=datastore/config">
                    <span class="fa fa-plus fa-fw"></span> Create Datastore
                </a>
            </div>
        </h3>
    </div>

    <div class="row">
        <div class="col-xs-12">
            <c:choose>
                <c:when test="${empty kapp.getFormsByType('Datastore')}">
                    <div class="table no-data text-center">
                        <h4>There are no datastores to display.</h4>
                        <a href="${bundle.kappLocation}/${form.slug}?page=datastore/config">
                            <span class="fa fa-plus fa-fw"></span> Create Datastore
                        </a>
                    </div>
                </c:when>
                <c:otherwise>
                    <table class="table table-hover datastore-list-table"> 
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Description</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${kapp.getFormsByType('Datastore')}" var="datastore">
                                <tr>
                                    <td><a href="${bundle.kappLocation}/${form.slug}?page=datastore/store&store=${datastore.slug}">${datastore.name}</a></td>
                                    <td>${datastore.description}</td>
                                    <td>
                                        <div class="btn-group pull-right">
                                            <a class="btn btn-xs btn-default" href="${bundle.kappLocation}/${form.slug}?page=datastore/config&store=${datastore.slug}">
                                                <span class="fa fa-cog fa-fw"></span>
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
    
    <!-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -------------------------------->
    <bundle:variable name="aside">
        <h3>${form.name}</h3>
        <p>${form.description}</p>
        <hr class="border-color-white" />
        <p>To add a new datastore, click the <b class="nowrap"><span class="fa fa-plus"></span> Create Datastore</b> button.</p>
        <p>To update a datastore, click the configure <b><span class="fa fa-cog"></span></b> button.</p>
        <p>To add new records to a datastore, click the name of the datastore.</p>
        <hr class="border-color-white" />
        <p><span class="fa fa-exclamation-circle"></span> Datastore forms cannot contain more than 1 page.</p>
    </bundle:variable>
    <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
    
</bundle:layout>