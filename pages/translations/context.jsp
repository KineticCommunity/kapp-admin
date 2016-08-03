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
                <li class="active">${text.titlelize(param.context)}</li>
            </ol>
            
            <div class="page-header">
                <div class="row">
                    <div class="col-xs-8">
                        <h3>
                            ${text.titlelize(param.context)}
                            <small> Translations</small>
                        </h3>
                    </div>
                    <div class="col-xs-4">
                        <select class="pull-right">
                            <option value="en">English</option>
                            <option value="en_US">English (US)</option>
                            <option value="fr_FR">French</option>
                        </select>
                    </div>
                </div>
            </div>       
            
            <div class="row">
                <div class="col-xs-12">
                    <table class="table table-hover datastore-list-table"> 
                        <thead>
                            <tr>
                                <th style="width:40%;">Key</th>
                                <th style="width:50%;">Value</th>
                                <th data-orderable="false" style="width:10%;"></th>
                            </tr>
                        </thead>
                        <tbody>
<%--                             <c:forEach var="entry" items="${}"> --%>
                                <tr>
                                    <td><a href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=translations/key&slug=${param.slug}&context=${param.context}&key=">Key</a></td>
                                    <td>Value</td>
                                    <td>
                                        <div class="btn-group view-mode pull-right" role="group">
                                            <button class="edit-button btn btn-xs btn-default" type="button"><span class="fa fa-pencil"></span></button>
                                            <button class="delete-button btn btn-xs btn-danger" type="button"><span class="fa fa-times"></span></button>
                                        </div>
                                        <div class="btn-group edit-mode pull-right hide" role="group">
                                            <button class="cancel-button btn btn-xs btn-danger" type="button"><span class="fa fa-times"></span></button>
                                            <button class="save-button btn btn-xs btn-success" type="button"><span class="fa fa-check"></span></button>
                                        </div>
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