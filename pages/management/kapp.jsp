<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<c:set var="console" value="${form}" scope="request"/>
<c:set var="currentKapp" value="${space.getKapp(param.kapp)}" scope="request"/>

<c:if test="${empty currentKapp}">
    <c:set var="error" value="${i18n.translate('No kapps with the slug SLUG exist.')
        .replace('SLUG', '<b>SLUG</b>')
        .replace('SLUG', param.kapp)}" />
</c:if>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <!-- Sets title and imports js and css specific to this console. -->
    <bundle:variable name="pageTitle">${text.escape(text.defaultIfBlank(currentKapp.name, 'Kapp'))} Management</bundle:variable>
    <bundle:variable name="head">
        <c:import url="${bundle.path}/partials/management/head.jsp" charEncoding="UTF-8"/>
    </bundle:variable>

    
    <!-- BREADCRUMBS START HERE. Remove if not needed. ------------------------------------------->
    <bundle:variable name="breadcrumb">
        <li><a href="${bundle.kappLocation}/${console.slug}">${console.name}</a></li>
        <c:choose>
            <c:when test="${not empty currentKapp}">
                <li class="active">${text.escape(currentKapp.name)}</li>
            </c:when>
            <c:otherwise>
                <li class="active">Kapp Not Found</li>
            </c:otherwise>
        </c:choose>
    </bundle:variable>
    <!-- BREADCRUMBS END HERE. ------------------------------------------------------------------->

    <c:choose>
        <c:when test="${empty error}">
        
            <!-- PAGE CONTENT STARTS HERE -------------------------------------------------------->
            
            <div class="page-header">
                <h2>
                    <span>${text.escape(currentKapp.name)}</span>
                    <small>Kapp Management</small>
                    <div class="pull-right users-table-buttons">
                        <a class="btn btn-tertiary" href="${bundle.kappLocation}/${console.slug}?page=management/config/kapp&kapp=${currentKapp.slug}">
                            <span class="fa fa-cog fa-fw"></span> Configure Kapp
                        </a>
                    </div>
                </h2>
            </div>
            
            <div class="row">
                <div class="col-xs-12 m-b-2">
                    <label>Updated</label>
                    <span data-moment-ago="${currentKapp.updatedAt}" data-toggle="tooltip"></span>
                    by <a href="${bundle.spaceLocation}?page=profile&username=${text.escapeUrlParameter(currentKapp.updatedBy)}">${currentKapp.updatedBy}</a>
                </div>
                <div class="col-xs-12">
                    <h4 class="m-t-4">Forms</h4>
                    <table class="table table-sm table-hover table-striped" data-table-forms-list> 
                        <thead>
                            <tr>
                                <th>Form</th>
                                <th>Type</th>
                                <th>Updated</th>
                                <th>Status</th>
                                <c:forEach var="attributeDefinition" items="${currentKapp.formAttributeDefinitions}">
                                    <th class="visibility-toggle" data-visible="false">
                                        ${text.escape(attributeDefinition.name)}
                                    </th>
                                </c:forEach>
                                <th data-orderable="false"></th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="currentForm" items="${currentKapp.forms}">
                                <tr>
                                    <td>
                                        <a href="${bundle.kappLocation}/${console.slug}?page=management/form&kapp=${currentKapp.slug}&form=${currentForm.slug}">
                                            ${text.escape(currentForm.name)}
                                        </a>
                                    </td>
                                    <td>${text.escape(currentForm.type.name)}</td>
                                    <td data-order="${currentForm.updatedAt}">
                                        <span data-moment-ago="${currentForm.updatedAt}" data-toggle="tooltip"></span>
                                    </td>
                                    <td><span class="label ${AdminHelper.getFormStatusLabelClass(form)}">${currentForm.status}</span></td>
                                    <c:forEach var="attributeDefinition" items="${currentKapp.formAttributeDefinitions}">
                                        <td class="visibility-toggle">
                                            <c:choose>
                                                <c:when test="${attributeDefinition.allowsMultiple}">
                                                    <c:forEach var="attributeValue" items="${currentForm.getAttributeValues(attributeDefinition.name)}">
                                                        ${attributeValue} <br />
                                                    </c:forEach>
                                                </c:when>
                                                <c:otherwise>
                                                    ${currentForm.getAttributeValue(attributeDefinition.name)}
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </c:forEach>
                                    <td class="text-right">
                                        <a class="btn btn-xs btn-tertiary"
                                           href="${bundle.kappLocation}/${console.slug}?page=management/config/form&kapp=${currentKapp.slug}&form=${currentForm.slug}">
                                            <span class="fa fa-cog fa-fw"></span>
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
            
            <%-- PAGE CONTENT ENDS HERE ---------------------------------------------------------%>
    
            <%-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -----------------------%>
<%--             <bundle:variable name="aside"> --%>
<!--                 <h3>Kapp Management</h3> -->
<%--                 <h5>${currentKapp.name}</h5> --%>
<!--                 <hr /> -->
<%--             </bundle:variable> --%>
            <%-- RIGHT SIDEBAR CONTENT ENDS HERE. -----------------------------------------------%>
            
            <%-- Clear saved states for DataTables on child pages --%>
            <span data-submissions-data-table-state-reset="recent-submissions-table,feedback-activity-table"></span>
            
        </c:when>
        <c:otherwise>
            <c:import url="${bundle.path}/partials/error.jsp" charEncoding="UTF-8">
                <c:param name="message" value="${error}"/>
            </c:import>
        </c:otherwise>
    </c:choose>
    
</bundle:layout>