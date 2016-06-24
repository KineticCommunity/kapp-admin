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
    <div class="wizard">
        <h2 class="text-center">
            ${kapp.name} Kapp Setup Wizard
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
            <c:when test="${SetupHelper.isAdminRequired() && !SetupHelper.isAdminExists()}">
                <div class="alert alert-danger">
                    <p>
                        <span class="fa fa-exclamation-triangle"></span>
                        This Kapp requires the Admin Kapp, which is not installed. Please install the Admin Kapp first before installing this Kapp.
                    </p>
                </div>
            </c:when>
            <c:when test="${SetupHelper.isAdminRequired() && !SetupHelper.isAdminValid()}">
                <div class="alert alert-danger">
                    <p>
                        <span class="fa fa-exclamation-triangle"></span>
                        This Kapp requires the Admin Kapp, which is not configured properly. Please configure the Admin Kapp first before installing this Kapp.
                    </p>
                </div>
            </c:when>
            <c:otherwise>
                <c:choose>
                    <c:when test="${Text.equals(param.step, 'attributes')}">
                        <div class="attributes-container">
                            <c:import url="${bundle.path}/setup/wizard/attributes.jsp" charEncoding="UTF-8"/>
                        </div>
                    </c:when>
                    <c:when test="${Text.equals(param.step, 'bridges')}">
                        <div class="bridges-container">
                            <c:import url="${bundle.path}/setup/wizard/bridges.jsp" charEncoding="UTF-8"/>
                        </div>
                    </c:when>
                    <c:when test="${Text.equals(param.step, 'categories')}">
                        <div class="categories-container">
                            <c:import url="${bundle.path}/setup/wizard/categories.jsp" charEncoding="UTF-8"/>
                        </div>
                    </c:when>
                    <c:when test="${Text.equals(param.step, 'formTypes')}">
                        <div class="form-types-container">
                            <c:import url="${bundle.path}/setup/wizard/formTypes.jsp" charEncoding="UTF-8"/>
                        </div>
                    </c:when>
                    <c:when test="${Text.equals(param.step, 'forms')}">
                        <div class="forms-container">
                            <c:import url="${bundle.path}/setup/wizard/forms.jsp" charEncoding="UTF-8"/>
                        </div>
                    </c:when>
                    <c:when test="${Text.equals(param.step, 'security')}">
                        <div class="security-container">
                            <c:import url="${bundle.path}/setup/wizard/security.jsp" charEncoding="UTF-8"/>
                        </div>
                    </c:when>
                    <c:when test="${Text.equals(param.step, 'webhooks')}">
                        <div class="webhooks-container">
                            <c:import url="${bundle.path}/setup/wizard/webhooks.jsp" charEncoding="UTF-8"/>
                        </div>
                    </c:when>
                    <c:when test="${Text.equals(param.step, 'adminKappForms')}">
                        <div class="admin-kapp-forms-container">
                            <c:import url="${bundle.path}/setup/wizard/adminKappForms.jsp" charEncoding="UTF-8"/>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <p class="text-center">This setup wizard will guide you through configuring the below components and data required for this Kapp to run.</p> 
                        <table class="table table-hover">
                            <tbody>
                                <tr class="empty-state-message info">
                                    <td colspan="2"><span class="fa fa-exclamation-circle"></span> <i>No required configurations are defined.</i></td>
                                </tr>
                                <c:forEach var="progress" items="${SetupHelper.getWizardProgress()}">
                                    <tr class="${progress.configured ? 'success' : 'danger'}">
                                        <td>
                                            <a class="fa fa-share" href="${bundle.kappLocation}?setup=wizard&step=${progress.slug}"></a> 
                                            ${progress.description}
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${progress.configured}">
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
                        <c:if test="${!SetupHelper.getWizardProgress().isEmpty()}">
                            <p class="text-center">
                                <a href="${bundle.kappLocation}?setup=wizard&step=${SetupHelper.getWizardNextStep(null)}" 
                                        class="btn btn-lg btn-primary">
                                    <b><span class="fa fa-play"></span> Start<b>
                                </a>
                            </p>
                        </c:if>
                        <c:set var="configurationStatusUpdated" value="${SetupHelper.updateKappConfigurationStatus()}"/>
                    </c:otherwise>
                </c:choose>
            </c:otherwise>
        </c:choose>
    </div>
</bundle:layout>