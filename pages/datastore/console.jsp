<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<%@include file="../../bundle/router.jspf" %>
<c:set var="currentKapp" value="${space.getKapp(param.kapp)}" scope="request" />

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <!-- Sets title and imports js and css specific to this console. -->
    <bundle:variable name="head">
        <c:import url="${bundle.path}/partials/${form.slug}/head.jsp" charEncoding="UTF-8"/>
    </bundle:variable>

    <!-- Show page content only if Kapp exists. Otherwise redirect to home page. -->
    <c:choose>
        <c:when test="${empty currentKapp}">
            <c:redirect url="${bundle.kappPath}"/>
        </c:when>
        <c:otherwise>
            
            <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
                        
            <div class="page-header">
                <h3>
                    ${form.name}
                    <div class="pull-right">
                        <a class="btn btn-sm btn-primary" href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=datastore/config">
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
                                <a href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=datastore/config">
                                    <span class="fa fa-plus fa-fw"></span> Create Datastore
                                </a>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <table class="table table-hover"> 
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
                                            <td><a href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=datastore/store&store=${datastore.slug}">${datastore.name}</a></td>
                                            <td>${datastore.description}</td>
                                            <td>
                                                <div class="btn-group pull-right">
                                                    <a class="btn btn-xs btn-default" href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=datastore/config&store=${datastore.slug}">
                                                        <span class="fa fa-pencil fa-fw"></span>
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
                <h3>Kinetic Datastore</h3>
                <p>
                    The listed datastores have been configured in the Datastore Console. 
                    Datastores are Kinetic Request forms that can be used to store data for use in other applications or on other forms. 
                    To add a new datastore, click the "Create Datastore" button.
                </p>
            </bundle:variable>
            <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
            
        </c:otherwise>
    </c:choose>
</bundle:layout>