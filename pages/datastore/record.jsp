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
                <li><a href="${bundle.kappLocation}/${form.slug}?&page=datastore/store&store=${currentStore.slug}" class="return-to-store">${currentStore.name}</a></li>
                <li class="active">${not empty param.id ? 'Edit' : empty param.clone ? 'New' : 'Clone'}</li>
            </bundle:variable>
            <!-- BREADCRUMBS END HERE. ------------------------------------------------------------------->
    
            <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
            
            <div class="page-header">
                <h2>${not empty param.id ? 'Edit ' : empty param.clone ? 'New ' : 'Clone '}${currentStore.name} Record</h2>
            </div>
            
            <div class="row">
                <div class="col-xs-12">
                    <div class="datastore-record-container embedded-form" data-datastore-slug="${currentStore.slug}"
                            data-record-id="${param.id}" data-clone-id="${param.clone}"
                            data-datastore-configuration="${text.escape(currentStore.getAttributeValue('Datastore Configuration'))}"></div>
                </div>
            </div>
            
            
            <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
    
            <!-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -------------------------------->
            <bundle:variable name="aside">
                <h3>${form.name}</h3>
                <h5>${currentStore.name}</h5>
                <p>${currentStore.description}</p>
            </bundle:variable>
            <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
            
        </bundle:layout>
        
    </c:otherwise>
</c:choose>