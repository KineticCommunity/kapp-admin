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
                <li><a href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=translations/kapp&slug=${param.slug}">${translationKapp.name}</a></li>
                <li><a href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=translations/context&slug=${param.slug}&context=${param.context}">${text.titlelize(param.context)}</a></li>
                <li class="active">${param.key}</li>
            </ol>
            
            <div class="page-header">
                <h3>
                    Key: ${param.key}
                    <small> Translations</small>
                </h3>
            </div>          
            
            <div class="row">
                <div class="col-xs-12">
                    <table class="table table-hover datastore-list-table"> 
                        <thead>
                            <tr>
                                <th style="width:50%;">Locale</th>
                                <th style="width:50%;">Value</th>
                            </tr>
                        </thead>
                        <tbody>
<%--                             <c:forEach var="entry" items="${}"> --%>
                                <tr>
                                    <td><a href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=translations/context&slug=${param.slug}&context=${param.context}&locale=en">en</a></td>
                                    <td><input class="form-control input-sm" type="text" value="en Value"/></td>
                                </tr>
                                <tr>
                                    <td><a href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=translations/context&slug=${param.slug}&context=${param.context}&locale=fr_FR">fr_FR</a></td>
                                    <td><input class="form-control input-sm" type="text" value="fr_FR Value"/></td>
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