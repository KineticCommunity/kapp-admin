<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <!-- Sets title and imports js and css specific to this console. -->
    <bundle:variable name="head">
        <title>Admin Console<c:if test="${not empty form}"> | ${form.name}</c:if></title>
        <c:import url="${bundle.path}/partials/${form.slug}/head.jsp" charEncoding="UTF-8"/>
    </bundle:variable>

    <c:set var="currentKapp" value="${space.getKapp(param.kapp)}" scope="request" />
    <c:set var="currentStore" value="${kapp.getForm(param.store)}" scope="request" />

    <!-- Show page content only if Kapp exists. Otherwise redirect to home page. -->
    <c:choose>
        <c:when test="${empty currentKapp}">
            <c:redirect url="${bundle.kappPath}"/>
        </c:when>
        <c:when test="${!identity.spaceAdmin}">
            <c:import url="${bundle.path}/partials/${form.slug}/adminError.jsp" charEncoding="UTF-8"/>
        </c:when>
        <c:otherwise>
            
            <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
            
            <ol class="breadcrumb">
                <li><a href="${bundle.kappLocation}/${form.slug}?kapp=${currentKapp.slug}">${form.name}</a></li>
                <li class="active ng-binding">${currentStore.name}</li>
            </ol>
            
            <div class="page-header">
                <h3>
                    ${currentStore.name} <small> Records</small>
                    <div class="pull-right datastore-records-table-buttons">
                        <a class="btn btn-sm btn-primary" href="${bundle.kappLocation}/${form.slug}?kapp=${currentKapp.slug}&page=datastore/record&store=${currentStore.slug}">
                            <span class="fa fa-plus fa-fw"></span> Add Record
                        </a>
                        <input class="hide" accept=".csv" id="datastore-records-import" type="file">
                    </div>
                </h3>
            </div>
        
            <div class="row">
                <div class="col-xs-12">
                    
                    <table style="width:100%" class="table table-hover table-striped table-bordered dt-responsive nowrap" id="datastore-records-table" 
                            data-console-slug="${form.slug}" data-datastore-slug="${currentStore.slug}" data-kapp-slug="${currentKapp.slug}">
                        <tr>
                            <td>
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
                <h3>${currentStore.name}</h3>
                <p>
                    ${currentStore.description}
                </p>
            </bundle:variable>
            <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
            
        </c:otherwise>
    </c:choose>
</bundle:layout>