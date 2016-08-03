<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<%@include file="../../bundle/router.jspf" %>
<c:set var="currentKapp" value="${space.getKapp(param.kapp)}" scope="request" />

<!-- Show page content only if Kapp exists. Otherwise redirect to valid page. -->
<c:choose>
    <c:when test="${empty currentKapp}">
        <script>window.location.replace("${bundle.kappLocation}");</script>
    </c:when>
    <c:otherwise>
    
        <bundle:layout page="${bundle.path}/layouts/layout.jsp">
            <!-- Sets title and imports js and css specific to this console. -->
            <bundle:variable name="head">
                <c:import url="${bundle.path}/partials/translations/head.jsp" charEncoding="UTF-8"/>
            </bundle:variable>

            <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
            
            <div class="page-header">
                <h3>${form.name}</h3>
            </div>
        
            <div class="row">
                <div class="col-xs-12">
                    <h4>Kapps</h4>
                </div>
            </div>
            
            
            <div class="row">
                <div class="col-xs-12">
                    <table class="table table-hover datastore-list-table"> 
                        <thead>
                            <tr>
                                <th>Kapp</th>
                                <th>Default Locale</th>
                                <th style="width:50%;">Enabled Locales</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="tKapp" items="${space.kapps}">
                                <tr>
                                    <td><a href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=translations/kapp&slug=${tKapp.slug}">${tKapp.name}</a></td>
                                    <td><span class="label label-primary">en_US</span></td>
                                    <td>
                                        <span class="label label-success">en</span>
                                        <span class="label label-success">en_US</span>
                                        <span class="label label-success">fr_FR</span>
                                        <span class="label label-success">es</span>
                                        <span class="label label-success">es_MX</span>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        
            <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
            
        </bundle:layout>
        
    </c:otherwise>
</c:choose>