<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="bundle/initialization.jspf" %>
<%@include file="bundle/router.jspf" %>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <bundle:variable name="head">
        <title>Admin Console</title>
    </bundle:variable>
    
    <div class="row">
        <div class="col-xs-10 col-xs-offset-1">
            <c:forEach var="console" items="${AdminHelper.getActiveAdminConsoles()}">
                <div class="col-xs-12">
                    <div class="bs-callout bs-callout-info">
                        <h4><a href="${bundle.kappLocation}?page=${console.slug}/${console.page}">${console.name}</a></h4>
                        <p>${console.description}</p>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>
</bundle:layout>