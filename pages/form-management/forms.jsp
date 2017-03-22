<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<c:set var="console" value="${form}" scope="request"/>
<c:set var="currentKapp" value="${space.getKapp(param.kapp)}" scope="request"/>

<!-- Show page content only if selected Kapp exists. -->
<c:choose>
    <c:when test="${empty currentKapp}">
        <script>window.location.replace("${bundle.kappLocation}/${form.slug}");</script>
    </c:when>
    <c:otherwise>
    
        <bundle:layout page="${bundle.path}/layouts/layout.jsp">
            <!-- Imports js and css specific to this console. -->
            <bundle:variable name="head">
                <c:import url="${bundle.path}/partials/form-management/head.jsp" charEncoding="UTF-8"/>
            </bundle:variable>
            
            <!-- BREADCRUMBS START HERE. Remove if not needed. ------------------------------------------->
            <bundle:variable name="breadcrumb">
                <li><a href="${bundle.kappLocation}/${form.slug}">${form.name}</a></li>
                <li class="active">${text.escape(currentKapp.name)}</li>
            </bundle:variable>
            <!-- BREADCRUMBS END HERE. ------------------------------------------------------------------->

            <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
            
            <div class="page-header">
                <div class="row">
                    <div class="col-xs-12">
                        <h3>
                            <span>${text.escape(currentKapp.name)}</span>
                            <small>Forms</small>
                        </h3>
                    </div>
                </div>
            </div>
            
            <div class="row">
                <div class="col-xs-12">
                    <table class="table table-sm table-hover table-striped form-management-forms" 
                           data-table-forms-list> 
                        <thead>
                            <tr>
                                <th>Form Name</th>
                                <th>Type</th>
                                <th>Status</th>
                                <th>Last Updated</th>
                                <c:forEach var="attributeDefinition" items="${currentKapp.formAttributeDefinitions}">
                                    <th class="visibility-toggle" data-visible="false">
                                        ${attributeDefinition.name}
                                    </th>
                                </c:forEach>
                                <th data-orderable="false"></th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="form" items="${currentKapp.forms}">
                                <tr>
                                    <td>
                                        <a href="${bundle.kappLocation}/${console.slug}?page=form-management/formActivity&kapp=${currentKapp.slug}&form=${form.slug}">
                                            ${text.escape(form.name)}
                                        </a>
                                    </td>
                                    <td>${form.type.name}</td>
                                    <td><span class="label ${AdminHelper.getFormStatusLabelClass(form)}">${form.status}</span></td>
                                    <td data-order="${form.updatedAt}">
                                        <span data-moment-ago="${form.updatedAt}" data-toggle="tooltip"></span>
                                    </td>
                                    <c:forEach var="attributeDefinition" items="${currentKapp.formAttributeDefinitions}">
                                        <td class="visibility-toggle">
                                            <c:choose>
                                                <c:when test="${attributeDefinition.allowsMultiple}">
                                                    <c:forEach var="attributeValue" items="${form.getAttributeValues(attributeDefinition.name)}">
                                                        ${attributeValue} <br />
                                                    </c:forEach>
                                                </c:when>
                                                <c:otherwise>
                                                    ${form.getAttributeValue(attributeDefinition.name)}
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </c:forEach>
                                    <td class="text-right">
                                        <a class="btn btn-xs btn-tertiary"
                                           href="${bundle.kappLocation}/${console.slug}?page=form-management/form&kapp=${currentKapp.slug}&form=${form.slug}">
                                            <span class="fa fa-pencil"></span>
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
            
            <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
    
            <!-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -------------------------------->
            <bundle:variable name="aside">
                <h3>${form.name}</h3>
                <h4>${currentKapp.name}</h4>
                <p>This is a listing of all forms in the <b class="nowrap">${currentKapp.name} </b> Kapp.</p>
                <hr class="border-color-white" />
                <h4>Instructions</h4>
                <p>To update a form's attributes click the link to the form in the first column.</p>
                <hr class="border-color-white" />
                <h4>Advanced Management</h4>
                <p>The <span class="strong">Kinetic Request</span> Management Console is for advanced configuration of portals and forms. Most common configurations can be made using this Admin Console.</p>
                <a target="_blank" href="${bundle.spaceLocation}/app/#/${currentKapp.slug}/author/forms" class="btn btn-block btn-default">
                    <span class="glyphicon glyphicon-cog pull-left" aria-hidden="true"></span> Kinetic Request
                </a>
                <p/>
            </bundle:variable>
            <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
            
        </bundle:layout>
        
    </c:otherwise>
</c:choose>