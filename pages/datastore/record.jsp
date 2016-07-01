<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<c:set var="currentKapp" value="${space.getKapp(param.kapp)}" scope="request" />
<c:set var="currentStore" value="${kapp.getForm(param.store)}" scope="request" />

<!-- Show page content only if Kapp & Store exist. Otherwise redirect to valid page. -->
<c:choose>
    <c:when test="${empty currentKapp}">
        <script>window.location.replace("${bundle.kappLocation}");</script>
    </c:when>
    <c:when test="${empty currentStore}">
        <script>window.location.replace("${bundle.kappLocation}/${form.slug}?kapp=${currentKapp.slug}");</script>
    </c:when>
    <c:otherwise>

        <bundle:layout page="${bundle.path}/layouts/layout.jsp">
            <!-- Sets title and imports js and css specific to this console. -->
            <bundle:variable name="head">
                <c:import url="${bundle.path}/partials/datastore/head.jsp" charEncoding="UTF-8"/>
            </bundle:variable>
    
            <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
            
            <ol class="breadcrumb">
                <li><a href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}">${form.name}</a></li>
                <li><a href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=datastore/store&store=${currentStore.slug}" class="return-to-store">${currentStore.name}</a></li>
                <li class="active ng-binding">${not empty param.id ? 'Edit' : empty param.clone ? 'New' : 'Clone'}</li>
            </ol>
            
            <div class="page-header">
                <h3>${not empty param.id ? 'Edit ' : empty param.clone ? 'New ' : 'Clone '}${currentStore.name} Record</h3>
            </div>
            
            <div class="row">
                <div class="col-xs-12">
<%-- TODO restrict duplicates <c:set var="uniqueFields" value="${AdminHelper.getUniqueFields(currentStore)}"/>  data-unique-fields="${uniqueFields}"--%>
                    <div class="datastore-record-container embedded-form" data-datastore-slug="${currentStore.slug}"
                            data-record-id="${param.id}" data-clone-id="${param.clone}"
                            data-datastore-configuration="${text.escape(kapp.getForm(currentStore.slug).getAttributeValue('Datastore Configuration'))}"></div>
                </div>
            </div>
            
            
            <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
    
            <!-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -------------------------------->
            <bundle:variable name="aside">
                <h3>${currentStore.name}</h3>
                <p>
                    ${currentStore.description}
                </p>
            </bundle:variable>
            <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
            
        </bundle:layout>
        
    </c:otherwise>
</c:choose>