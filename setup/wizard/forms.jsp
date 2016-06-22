<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<hr /><c:import url="${bundle.path}/setup/wizard/progress.jsp" charEncoding="UTF-8"/><hr />

<!-- FORMS -->
<div class="forms text-left">
    <h3>Forms</h3>
    <table class="table table-hover">
        <thead>
            <tr>
                <th>Name</th>
                <th>Description</th>
                <th>Slug</th>
                <th>Type</th>
                <th>Status</th>
                <th width="10%"></th>
            </tr>
        </thead>
        <tbody>
            <c:forEach items="${SetupHelper.getForms()}" var="form">
                <tr data-json="${Text.escape(Json.toString(form))}" class="${form.exists ? 'success' : 'danger'}">
                    <td>${form.name}</td>
                    <td>${form.description}</td>
                    <td>${form.slug}</td>
                    <td>${form.type}</td>
                    <td>${form.status}</td>
                    <td>
                        <c:choose>
                            <c:when test="${form.exists}">
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