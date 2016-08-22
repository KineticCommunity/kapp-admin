<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<hr /><c:import url="${bundle.path}/setup/wizard/progress.jsp" charEncoding="UTF-8"/><hr />

<!-- CATEGORIES -->
<div class="category-definitions text-left">
    <h3>Category Definitions</h3>
    <table class="table table-hover">
        <thead>
            <tr>
                <th>Name</th>
                <th>Slug</th>
                <th width="10%"></th>
            </tr>
        </thead>
        <tbody>
            <c:forEach items="${SetupHelper.getCategories()}" var="category">
                <c:set var="json" value="${Text.escape(Json.toString(category))}"/>
                <c:choose>
                    <c:when test="${not empty kapp.getCategory(category.slug)}">
                        <c:set var="category" value="${kapp.getCategory(category.slug)}"/>
                        <c:set var="status" value="${true}"/>
                    </c:when>
                    <c:otherwise><c:set var="status" value="${false}"/></c:otherwise>
                </c:choose>
                <tr data-json="${status ? '' : json}" data-status="${status}" class="${status ? 'success' : 'warning'}">
                    <td>${category.name}</td>
                    <td>${category.slug}</td>
                    <td>
                        <c:choose>
                            <c:when test="${status}">
                                <span class="label label-success"><span class="fa fa-check"></span> Configured</span>
                            </c:when>
                            <c:otherwise>
                                <span class="label label-danger"><span class="fa fa-times"></span> Not Configured</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                </tr>
            </c:forEach>
            
        </tbody>
    </table>
</div>

<c:import url="${bundle.path}/setup/wizard/navigation.jsp" charEncoding="UTF-8"/>