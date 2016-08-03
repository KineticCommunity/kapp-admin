<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<c:set var="currentKapp" value="${space.getKapp(param.kapp)}" scope="request" />
<c:set var="translationKapp" value="${space.getKapp(param.slug)}" scope="request" />

<!-- Show page content only if Kapp exists. Otherwise redirect to valid page. -->
<c:choose>
    <c:when test="${empty currentKapp}">
        <script>window.location.replace("${bundle.kappLocation}");</script>
    </c:when>
    <c:when test="${empty translationKapp}">
        <script>window.location.replace("${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}");</script>
    </c:when>
    <c:otherwise>
    

        <bundle:layout page="${bundle.path}/layouts/layout.jsp">
            <!-- Sets title and imports js and css specific to this console. -->
            <bundle:variable name="head">
                <c:import url="${bundle.path}/partials/translations/head.jsp" charEncoding="UTF-8"/>
            </bundle:variable>

            <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
            
            <ol class="breadcrumb">
                <li><a href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}">Translations</a></li>
                <li class="active">${translationKapp.name}</li>
            </ol>
            
            <div class="page-header">
                <h3>
                    ${translationKapp.name}
                    <div class="pull-right">
                        <a class="btn btn-sm btn-primary" href="#">
                            <span class="fa fa-download fa-fw"></span> Export
                        </a>
                        <a class="btn btn-sm btn-primary" href="#">
                            <span class="fa fa-upload fa-fw"></span> Import
                        </a>
                        <a class="btn btn-sm btn-default" href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&slug=${param.slug}&page=locales">
                            <span class="fa fa-cog fa-fw"></span> Locales
                        </a>
                    </div>
                </h3>
            </div>
            
            <div class="row">
                <div class="col-xs-12">
                    <h4>Core Contexts</h4>
                </div>
                <div class="col-xs-12">
                    <table class="table table-hover datastore-list-table"> 
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th data-orderable="false">Available Locales</th>
                            </tr>
                        </thead>
                        <tbody>
<%--                             <c:forEach var="context" items="${}"> --%>
                                <tr>
                                    <td>
                                        <a href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=translations/context&slug=${param.slug}&context=${context.name}">Shared${context.displayName}</a>
                                        <a class="btn btn-xs btn-warning" href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=translations/missing&slug=${param.slug}&context=${context.name}">6 Missing Translations</a>
                                    </td>
                                    <td>
                                        <a class="btn btn-xs btn-success" href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=translations/context&slug=${param.slug}&context=${context.name}&locale=en">en</a>
                                        <a class="btn btn-xs btn-success" href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=translations/context&slug=${param.slug}&context=${context.name}&locale=en_US">en_US</a>
                                        <a class="btn btn-xs btn-success" href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=translations/context&slug=${param.slug}&context=${context.name}&locale=fr_FR">fr_FR</a>
                                        <a class="btn btn-xs btn-success" href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=translations/context&slug=${param.slug}&context=${context.name}&locale=es">es</a>
                                        <a class="btn btn-xs btn-success" href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=translations/context&slug=${param.slug}&context=${context.name}&locale=es_MX">es_MX</a>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <a href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=translations/context&slug=${param.slug}&context=${context.name}">Bundle${context.displayName}</a>
                                    </td>
                                    <td>
                                        <a class="btn btn-xs btn-success" href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=translations/context&slug=${param.slug}&context=${context.name}&locale=en">en</a>
                                        <a class="btn btn-xs btn-success" href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=translations/context&slug=${param.slug}&context=${context.name}&locale=en_US">en_US</a>
                                        <a class="btn btn-xs btn-success" href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=translations/context&slug=${param.slug}&context=${context.name}&locale=fr_FR">fr_FR</a>
                                        <a class="btn btn-xs btn-success" href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=translations/context&slug=${param.slug}&context=${context.name}&locale=es">es</a>
                                        <a class="btn btn-xs btn-success" href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=translations/context&slug=${param.slug}&context=${context.name}&locale=es_MX">es_MX</a>
                                    </td>
                                </tr>
<%--                             </c:forEach> --%>
                        </tbody>
                    </table>
                </div>
            </div>
            
            <div class="row">
                <div class="col-xs-12">
                    <h4>Form Contexts</h4>
                </div>
                <div class="col-xs-12">
                    <table class="table table-hover datastore-list-table" id="dt-test"> 
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Slug</th>
                                <th>Type</th>
                                <th data-orderable="false">Available Locales</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="translationForm" items="${translationKapp.forms}">
                                <tr>
                                    <td>
                                        <a href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=translations/context&slug=${param.slug}&context=${translationForm.slug}">${translationForm.name}</a>
                                    </td>
                                    <td>${translationForm.slug}</td>
                                    <td>${translationForm.typeName}</td>
                                    <td>
                                        <a class="btn btn-xs btn-success" href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=translations/context&slug=${param.slug}&context=${translationForm.slug}&locale=en">en</a>
                                        <a class="btn btn-xs btn-success" href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=translations/context&slug=${param.slug}&context=${translationForm.slug}&locale=en_US">en_US</a>
                                        <a class="btn btn-xs btn-success" href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=translations/context&slug=${param.slug}&context=${translationForm.slug}&locale=fr_FR">fr_FR</a>
                                        <a class="btn btn-xs btn-success" href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=translations/context&slug=${param.slug}&context=${translationForm.slug}&locale=es">es</a>
                                        <a class="btn btn-xs btn-success" href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=translations/context&slug=${param.slug}&context=${translationForm.slug}&locale=es_MX">es_MX</a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
            
            <div class="row">
                <div class="col-xs-12">
                    <h4>Custom Contexts</h4>
                </div>
                <div class="col-xs-12">
                    <table class="table table-hover datastore-list-table"> 
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th data-orderable="false">Available Locales</th>
                            </tr>
                        </thead>
                        <tbody>
<%--                             <c:forEach var="context" items="${}"> --%>
                                <tr>
                                    <td>
                                        <a href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=translations/context&slug=${param.slug}&context=">Custom${context.name}</a>
                                    </td>
                                    <td>
                                        <a class="btn btn-xs btn-success" href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=translations/context&slug=${param.slug}&context=&locale=en">en</a>
                                        <a class="btn btn-xs btn-success" href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=translations/context&slug=${param.slug}&context=&locale=en_US">en_US</a>
                                        <a class="btn btn-xs btn-success" href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=translations/context&slug=${param.slug}&context=&locale=fr_FR">fr_FR</a>
                                        <a class="btn btn-xs btn-success" href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=translations/context&slug=${param.slug}&context=&locale=es">es</a>
                                        <a class="btn btn-xs btn-success" href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=translations/context&slug=${param.slug}&context=&locale=es_MX">es_MX</a>
                                    </td>
                                </tr>
<%--                             </c:forEach> --%>
                        </tbody>
                    </table>
                </div>
            </div>
        
            <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
            
        </bundle:layout>
        
    </c:otherwise>
</c:choose>