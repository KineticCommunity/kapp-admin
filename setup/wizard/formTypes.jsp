<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<hr /><c:import url="${bundle.path}/setup/wizard/progress.jsp" charEncoding="UTF-8"/><hr />

<!-- FORM TYPES -->
<div class="form-types text-left">
    <h3>Form Types</h3>
    <table class="table table-hover">
        <thead>
            <tr>
                <th>Name</th>
                <th width="10%"></th>
            </tr>
        </thead>
        <tbody>
            <c:forEach items="${SetupHelper.getFormTypes()}" var="formType">
                <c:set var="formTypeStatus" value="${not empty kapp.getFormType(formType.name)}"/>
                <tr data-json="${Text.escape(Json.toString(formType))}" data-status="${formTypeStatus}" class="${formTypeStatus ? 'success' : 'danger'}">
                    <td>${formType.name}</td>
                    <td>
                        <c:choose>
                            <c:when test="${formTypeStatus}">
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