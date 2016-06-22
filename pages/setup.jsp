<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../bundle/initialization.jspf" %>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <div class="no-data">
        <c:choose>
            <c:when test="${!identity.spaceAdmin}">
                <div class="alert alert-danger">
                    <h4>The setup for this application is not complete.</h4>
                    <p>Please contact your administrator.</p>
                </div>
            </c:when>
            <c:when test="${identity.spaceAdmin}">
                <h2>
                    ${kapp.name} Kapp Setup
                </h2>
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th width="10%">Level</th>
                            <th width="10%">Status</th>
                            <th width="10%">Required?</th>
                            <th>Name</th>
                            <th>Description</th>
        
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${SetupHelper.getConfigurationAttributes()}" var="setupAttributeEntryMap">
                            <c:forEach items="${setupAttributeEntryMap.value}" var="setupAttributeEntry">
                                <tr class="text-left ${setupAttributeEntry.isApplicableToPage()? setupAttributeEntry.isHasValue() ? 'success' : setupAttributeEntry.isRequired() ? 'danger' : 'warning' : 'info'}">
                                    <td>${text.titlelize(setupAttributeEntryMap.key)}</td>
                                    <td>
                                        <c:if test="${setupAttributeEntry.isApplicableToPage()}">
                                            <span class="fa ${setupAttributeEntry.isHasValue() ? "fa-check" : "fa-exclamation-triangle"}"></span>
                                            <c:choose>
                                                <c:when test="${setupAttributeEntry.isHasValue()}">
                                                    Found
                                                </c:when>
                                                <c:otherwise>
                                                    <c:choose>
                                                        <c:when test="${text.equals(setupAttributeEntryMap.key, 'space')}">
                                                            <a href="${bundle.spaceLocation}/app/#/${kapp.slug}/space/attributes">Missing</a>
                                                        </c:when>
                                                        <c:when test="${text.equals(setupAttributeEntryMap.key, 'kapp')}">
                                                            <a href="${bundle.spaceLocation}/app/#/${kapp.slug}/setup/kapp/attributes">Missing</a>
                                                        </c:when>
                                                        <c:when test="${text.equals(setupAttributeEntryMap.key, 'form')}">
                                                            <a href="${bundle.spaceLocation}/app/#/${kapp.slug}/author/form/${form.slug}/attributes">Missing</a>
                                                        </c:when>
                                                        <c:otherwise>
                                                            Missing
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:if>
                                    </td>
                                    <td class="${setupAttributeEntry.isRequired() ? "required" : "optional"}">
                                        ${setupAttributeEntry.isRequired() ? "Required" : "Optional"}
                                    </td>
                                    <td>${setupAttributeEntry.getName()}</td>
                                    <td>${setupAttributeEntry.getDescription()}</td>
                                </tr>
                            </c:forEach>
                        </c:forEach>
                    </tbody>
                </table>
        
                <p class="text-muted">
                    To update your attribute values visit <c:if test="${not empty form}"><a href="${bundle.spaceLocation}/app/#/${kapp.slug}/author/form/${form.slug}/attributes">
                    Form Attributes</a>, </c:if> <a href="${bundle.spaceLocation}/app/#/${kapp.slug}/setup/kapp/attributes">
                    Kapp Attributes</a><c:if test="${not empty form}">,</c:if> or <a href="${bundle.spaceLocation}/app/#/${kapp.slug}/space/attributes">
                    Space Attributes</a>.
                </p>
                <p class="text-muted">
                    To define your attributes visit <c:if test="${not empty form}"><a href="${bundle.spaceLocation}/app/#/${kapp.slug}/setup/attributeDefinitions/Form/new">
                    Form Attribute Definitions</a>,</c:if> <a href="${bundle.spaceLocation}/app/#/${kapp.slug}/setup/attributeDefinitions/Kapp/new">
                    Kapp Attribute Definitions</a><c:if test="${not empty form}">,</c:if> or <a href="${bundle.spaceLocation}/app/#/${kapp.slug}/attributeDefinitions/Space/new">
                    Space Attribute Definitions</a>.
                </p>
            </c:when>
        </c:choose>
    </div>
</bundle:layout>