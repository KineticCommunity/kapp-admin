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
                <c:set var="categoryStatus" value="${not empty kapp.getCategory(category.slug)}"/>
                <tr data-json="${Text.escape(Json.toString(category))}" data-status="${categoryStatus}" class="${categoryStatus ? 'success' : 'danger'}">
                    <td>${category.name}</td>
                    <td>${category.slug}</td>
                    <td>
                        <c:choose>
                            <c:when test="${categoryStatus}">
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