<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="bundle/initialization.jspf" %>
<%@include file="bundle/router.jspf" %>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    
    <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
                
    <div class="page-header">
        <h3 class="text-center">
            Welcome to the <strong>Admin Console</strong>
        </h3>
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
                            <a class="card-xs card-secondary card-subtle" href="${bundle.kappLocation}/${console.slug}">
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
        </div>
    </div>

    <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
    
    <!-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -------------------------------->
    <bundle:variable name="aside">
    
    </bundle:variable>
    <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
    
</bundle:layout>