<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="bundle/initialization.jspf" %>
<%@include file="bundle/router.jspf" %>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <bundle:variable name="head">
        <title>Admin Console</title>
    </bundle:variable>
    
    <br/>
    
    <div class="row">
        <div class="col-xs-8 ${empty param.kapp ? 'col-xs-offset-2' : ''} ">
            <c:set var="currentKapp" value="${empty param.kapp ? kapp : space.getKapp(param.kapp)}" />
            <c:forEach var="form" items="${kapp.forms}">
                <c:if test="${text.equals(form.type.name, 'Console') && (not empty param.kapp  && form.hasAttributeValue('Kapp Slug',currentKapp.slug) || (empty param.kapp && form.hasAttribute('Kapp Slug')))}">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <strong>${form.name}</strong>
                        </div>
                        <div class="panel-body">
                            <p>${form.description}</p>
                            <c:if test="${empty param.kapp}">
                                <table class="table table-hover">
                                    <thead>
                                        <tr>
                                            <th>Kapp</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="kapp" items="${space.kapps}">
                                            <c:if test="${form.hasAttributeValue('Kapp Slug',kapp.slug) && empty param.kapp}">
                                                <tr>
                                                    <td>
                                                        <a href="${bundle.kappLocation}/${form.slug}?kapp=${kapp.slug}">${kapp.name}</a>
                                                    </td>
                                                </tr>
                                            </c:if>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </c:if>
                        </div>
                    </div>
                </c:if>
            </c:forEach>
        </div>
    </div>
</bundle:layout>