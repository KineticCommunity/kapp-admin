<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="bundle/initialization.jspf" %>
<%@include file="bundle/router.jspf" %>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <bundle:variable name="head">
        <title>Admin Console</title>
    </bundle:variable>
    
    <br/>
    
    <div class="row">
        <div class="col-xs-8 col-xs-offset-2">
            <c:forEach var="console" items="${AdminHelper.getActiveAdminConsoles()}">
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h3>${console.name}</h3>
                    </div>
                    <div class="panel-body">
                        <p>${console.description}</p>
                    </div>
                    <div class="panel-footer">
                        <c:forEach var="kapp" items="${space.kapps}">
                            <a href="${bundle.kappLocation}?page=${console.slug}/${console.page}&kapp=${kapp.slug}"><input type="button" class="btn btn-primary" value="${kapp.name}"></a>
                        </c:forEach>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>
</bundle:layout>