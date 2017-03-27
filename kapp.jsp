<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="bundle/initialization.jspf" %>
<%@include file="bundle/router.jspf" %>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    
    <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
                
    <div class="page-header" id="admin-console-home">
        <h1 class="text-center">
            Welcome to the <strong>Admin Console</strong>
        </h1>
        <p class="text-center">
            Please select a console component below.
        </p>
    </div>

    <div class="row">
        <div class="col-xs-12">
            <div class="card-container-xs-12 card-container-sm-6 card-container-md-4">
                <c:set var="consoles" value="${AdminHelper.getActiveConsoles()}" scope="request" />
                <c:choose>
                    <c:when test="${not empty consoles}">
                        <c:forEach var="console" items="${consoles}">
                            <a class="card-xs card-primary card-subtle" href="${bundle.kappLocation}/${console.slug}">
                                <div class="card-title">${console.name}</div>
                                <div class="card-content">${console.description}</div>
                            </a>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="alert alert-info">
                            There are no Admin Console Components available for you.
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <c:if test="${identity.spaceAdmin}">
                <hr class="border-color-white" />
                <div class="text-center">
                    <h3 class="carh-title">Advanced Management</h3>
                    <p>
                        The
                        <a target="_blank" href="${bundle.spaceLocation}/app" class="btn btn-default btn-xs">
                          <span class="fa fa-cog fa-fw" aria-hidden="true"></span> Kinetic Request
                        </a>
                        Management Console is for advanced configuration of portals and forms. Most common configurations can be made using the above consoles.
                    </p>
                    <p>
                        The
                        <a target="_blank" href="${space.getAttributeValue('Task Server Url')}" class="btn btn-default btn-xs">
                          <span class="fa fa-cog fa-fw" aria-hidden="true"></span> Kinetic Task
                        </a>
                        Management Console is for advanced configuration workflow and automation functions.
                    </p>
                </div>
            </c:if>
        </div>
    </div>

    <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
    
    <!-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -------------------------------->
    <bundle:variable name="aside">
    </bundle:variable>
    <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
    
</bundle:layout>