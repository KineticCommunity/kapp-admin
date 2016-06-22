<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="bundle/initialization.jspf" %>
<%@include file="bundle/router.jspf" %>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <bundle:variable name="head">
        <title>Admin Console</title>
    </bundle:variable>
    
    <br/>

    <c:set var="currentKapp" value="${space.getKapp(param.kapp)}" scope="request" />
    <c:set var="consoles" value="${empty currentKapp ? AdminHelper.getActiveConsoles() : AdminHelper.getActiveConsolesForKapp(currentKapp)}" scope="request" />
    
    <div class="row">
        <div class="${empty currentKapp ? 'col-xs-8 col-xs-offset-2' : 'col-xs-10'} ">
            <c:choose>
                <c:when test="${empty consoles}">
                    <div class="alert alert-info">
                        <h4>There are no configured admin consoles<c:if test="${not empty currentKapp}"> for the ${currentKapp.name} Kapp</c:if>.</h4>
                        <c:choose>
                            <c:when test="${!identity.spaceAdmin}">
                                <p>Please contact your administrator.</p>
                            </c:when>
                            <c:otherwise>
                                <p>TODO: Instructions for setting up the consoles.</p>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="console" items="${consoles}">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <strong>${console.name}</strong>
                            </div>
                            <div class="panel-body">
                                <p>${console.description}</p>
                                <c:if test="${empty currentKapp}">
                                    <table class="table table-hover">
                                        <thead>
                                            <tr>
                                                <th>Kapp</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="activeKapp" items="${AdminHelper.getActiveKappsForConsole(console)}">
                                                <tr>
                                                    <td>
                                                        <a href="${bundle.kappLocation}/${console.slug}?kapp=${activeKapp.slug}">${activeKapp.name}</a>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </c:if>
                            </div>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</bundle:layout>