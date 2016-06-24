<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<hr /><c:import url="${bundle.path}/setup/wizard/progress.jsp" charEncoding="UTF-8"/><hr />

<!-- ADMIN KAPP FORMS -->
<div class="admin-kapp-forms text-left">
    <h3>Admin Kapp Forms</h3>
    <p>
        The following forms should be created during the configuration of the Admin Kapp and are required dependencies for this Kapp. 
        If any of these forms are not configured, please verify that the Admin Kapp is properly configured.
    </p>
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
            <tr class="empty-state-message">
                <td colspan="6"><i>No required Admin Kapp Forms.</i></td>
            </tr>
            <c:forEach items="${SetupHelper.getAdminKappForms()}" var="form">
                <c:if test="${!form.hasFormDefinition()}">
                    <tr class="${form.exists ? 'success' : 'danger'}">
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
                </c:if>
            </c:forEach>
        </tbody>
    </table>
</div>
<hr />    
<!-- CUSTOM ADMIN KAPP FORMS -->
<div class="custom-admin-kapp-forms text-left" data-admin-kapp-slug="${SetupHelper.adminKapp.slug}">    
    <h3>Custom Admin Kapp Forms</h3>
    <p>The following forms are specific to this Kapp and required to exist in the Admin Kapp. This setup wizard will create any of these forms that are not yet configured.</p>
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
            <tr class="empty-state-message">
                <td colspan="6"><i>No required Custom Admin Kapp Forms.</i></td>
            </tr>
            <c:forEach items="${SetupHelper.getAdminKappForms()}" var="form">
                <c:if test="${form.hasFormDefinition()}">
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
                </c:if>
            </c:forEach>
        </tbody>
    </table>
</div>

<c:import url="${bundle.path}/setup/wizard/navigation.jsp" charEncoding="UTF-8"/>