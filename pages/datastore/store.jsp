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
                            data-datastore-name="${currentStore.name}" data-datastore-slug="${currentStore.slug}" 
                            data-console-slug="${form.slug}" data-kapp-slug="${currentKapp.slug}">
                        <tr>
                            <td class="alert alert-info">
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
            
        </bundle:layout>
        
    </c:otherwise>
</c:choose>