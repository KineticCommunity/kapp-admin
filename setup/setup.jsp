<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../bundle/initialization.jspf" %>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <!-- Sets imports js and css specific to the setup pages. -->
    <bundle:variable name="head">
        <bundle:stylepack>
            <bundle:style src="${bundle.location}/setup/setup.css"/>
        </bundle:stylepack>
        <bundle:scriptpack>
            <bundle:script src="${bundle.location}/setup/setup.js" />
        </bundle:scriptpack>    
    </bundle:variable>
    <div class="no-data">
        <h2>
            ${kapp.name} Kapp Setup
        </h2>
        <c:choose>
            <c:when test="${!identity.spaceAdmin}">
                <c:choose>
                    <c:when test="${!SetupHelper.isConfigured() || !SetupHelper.isValid() || SetupHelper.isMissingAttributes()}">
                        <div class="alert alert-danger">
                            <h4>The setup for this application is not complete.</h4>
                            <p>Please contact your administrator.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="alert alert-danger">
                            <h4>You do not have access to this page.</h4>
                        </div>
                    </c:otherwise>
                </c:choose>
            </c:when>
            <c:otherwise>
                <p class="${!SetupHelper.isValid() ? 'alert alert-danger' : ''}">
                    <c:if test="${!SetupHelper.isValid()}"><span class="fa fa-exclamation-triangle"></span></c:if>
                    This Kapp is ${SetupHelper.isValid() ? 'configured' : '<b>NOT</b> configured properly'}. 
                    To update the configuration, visit the <a href="${bundle.kappLocation}?setup=wizard">Setup Wizard</a>.
                </p>
                
                <c:if test="${SetupHelper.isAdminRequired()}">
                    <c:choose>
                        <c:when test="${!SetupHelper.isAdminExists()}">
                            <div class="alert alert-danger">
                                <p>
                                    <span class="fa fa-exclamation-triangle"></span>
                                    This Kapp requires the Admin Kapp, which is not installed. Please install the Admin Kapp.
                                </p>
                            </div>
                        </c:when>
                        <c:when test="${!SetupHelper.isAdminValid()}">
                            <div class="alert alert-danger">
                                <p>
                                    <span class="fa fa-exclamation-triangle"></span>
                                    This Kapp requires the Admin Kapp, which is not configured properly. Please configure the Admin Kapp.
                                </p>
                            </div>
                        </c:when>
                    </c:choose>
                </c:if>
                
                <div class="text-left">                
                    <h3>Configured Attributes</h3>
                    <table class="table table-hover">
                        <thead>
                            <tr>
                                <th width="9%">Level</th>
                                <th width="10%">Status</th>
                                <th width="10%">Required?</th>
                                <th>Name</th>
                                <th>Description</th>
            
                            </tr>
                        </thead>
                        <tbody>
                            <tr class="empty-state-message">
                                <td colspan="2"><i>No configured attributes.</i></td>
                            </tr>
                            <!-- SPACE ATTRIBUTES -->
                            <c:forEach items="${SetupHelper.getSpaceAttributeDefinitions()}" var="setupAttribute">
                                <tr class="text-left ${setupAttribute.hasAttributeValues() ? 'success' : (setupAttribute.isRequired() ? 'danger' : 'warning')}">
                                    <td>Space</td>
                                    <td>
                                        <span class="fa ${setupAttribute.hasAttributeValues() ? 'fa-check' : (setupAttribute.isRequired() ? 'fa-exclamation-triangle text-danger' : 'fa-info-circle')}"></span>
                                        <c:choose>
                                            <c:when test="${setupAttribute.hasAttributeValues()}">Found</c:when>
                                            <c:otherwise><a href="${bundle.spaceLocation}/app/#/${kapp.slug}/space/attributes">Missing</a></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>${setupAttribute.isRequired() ? '<b>Required</b>' : 'Optional'}</td>
                                    <td>${setupAttribute.name}</td>
                                    <td>${setupAttribute.description}</td>
                                </tr>
                            </c:forEach>
                            <!-- KAPP ATTRIBUTES -->
                            <c:forEach items="${SetupHelper.getKappAttributeDefinitions()}" var="setupAttribute">
                                <tr class="text-left ${setupAttribute.isApplicable() ? (setupAttribute.hasAttributeValues() ? 'success' : (setupAttribute.isRequired() ? 'danger' : 'warning')) : 'info'}">
                                    <td>Kapp</td>
                                    <td>
                                        <c:if test="${setupAttribute.isApplicable()}">
                                            <span class="fa ${setupAttribute.hasAttributeValues() ? 'fa-check' : (setupAttribute.isRequired() ? 'fa-exclamation-triangle text-danger' : 'fa-info-circle')}"></span>
                                            <c:choose>
                                                <c:when test="${setupAttribute.hasAttributeValues()}">Found</c:when>
                                                <c:otherwise><a href="${bundle.spaceLocation}/app/#/${kapp.slug}/setup/kapp/attributes">Missing</a></c:otherwise>
                                            </c:choose>
                                        </c:if>
                                    </td>
                                    <td>${setupAttribute.isRequired() ? '<b>Required</b>' : 'Optional'}</td>
                                    <td>${setupAttribute.name}</td>
                                    <td>${setupAttribute.description}</td>
                                </tr>
                            </c:forEach>
                            <!-- FORM ATTRIBUTES -->
                            <c:forEach items="${SetupHelper.getFormAttributeDefinitions()}" var="setupAttribute">
                                <tr class="text-left ${setupAttribute.isApplicable() ? (setupAttribute.hasAttributeValues() ? 'success' : (setupAttribute.isRequired() ? 'danger' : 'warning')) : 'info'}">
                                    <td>Form</td>
                                    <td>
                                        <c:if test="${setupAttribute.isApplicable()}">
                                            <span class="fa ${setupAttribute.hasAttributeValues() ? 'fa-check' : (setupAttribute.isRequired() ? 'fa-exclamation-triangle text-danger' : 'fa-info-circle')}"></span>
                                            <c:choose>
                                                <c:when test="${setupAttribute.hasAttributeValues()}">Found</c:when>
                                                <c:otherwise><a href="${bundle.spaceLocation}/app/#/${kapp.slug}/author/form/${form.slug}/attributes">Missing</a></c:otherwise>
                                            </c:choose>
                                        </c:if>
                                    </td>
                                    <td>${setupAttribute.isRequired() ? '<b>Required</b>' : 'Optional'}</td>
                                    <td>${setupAttribute.name}</td>
                                    <td>${setupAttribute.description}</td>
                                </tr>
                            </c:forEach>
                            <!-- CATEGORY ATTRIBUTES -->
                            <c:forEach items="${SetupHelper.getCategoryAttributeDefinitions()}" var="setupAttribute">
                                <tr class="text-left info">
                                    <td>Category</td>
                                    <td><!-- Category attributes are never applicable --></td>
                                    <td>${setupAttribute.isRequired() ? '<b>Required</b>' : 'Optional'}</td>
                                    <td>${setupAttribute.name}</td>
                                    <td>${setupAttribute.description}</td>
                                </tr>
                            </c:forEach>
                            <!-- USER ATTRIBUTES -->
                            <c:forEach items="${SetupHelper.getUserAttributeDefinitions()}" var="setupAttribute">
                                <tr class="text-left info">
                                    <td>User</td>
                                    <td><!-- User attributes are never applicable --></td>
                                    <td>${setupAttribute.isRequired() ? '<b>Required</b>' : 'Optional'}</td>
                                    <td>${setupAttribute.name}</td>
                                    <td>${setupAttribute.description}</td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                    <p class="text-muted text-center">
                        To update your attribute values visit <c:if test="${not empty form}"><a href="${bundle.spaceLocation}/app/#/${kapp.slug}/author/form/${form.slug}/attributes">
                        Form Attributes</a>, </c:if> <a href="${bundle.spaceLocation}/app/#/${kapp.slug}/setup/kapp/attributes">
                        Kapp Attributes</a><c:if test="${not empty form}">,</c:if> or <a href="${bundle.spaceLocation}/app/#/${kapp.slug}/space/attributes">
                        Space Attributes</a>.
                    </p>
                    <p class="text-muted text-center">
                        To define your attributes visit <c:if test="${not empty form}"><a href="${bundle.spaceLocation}/app/#/${kapp.slug}/setup/attributeDefinitions/Form/new">
                        Form Attribute Definitions</a>,</c:if> <a href="${bundle.spaceLocation}/app/#/${kapp.slug}/setup/attributeDefinitions/Kapp/new">
                        Kapp Attribute Definitions</a><c:if test="${not empty form}">,</c:if> or <a href="${bundle.spaceLocation}/app/#/${kapp.slug}/attributeDefinitions/Space/new">
                        Space Attribute Definitions</a>.
                    </p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</bundle:layout>