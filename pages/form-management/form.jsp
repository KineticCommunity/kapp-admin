<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<!-- Set Varibles Needed To Build DOM Elements -->
<c:set var="currentKapp" value="${space.getKapp(param.kapp)}" scope="request"/>
<c:set var="currentObj" value="${space.getKapp(param.kapp).getForm(param.form)}" scope="request"/>
<c:set var="groupList" value="${GroupHelper.getGroupsFlattened()}" scope="request"/>
<c:set var="attributeDefinitions" value="${currentKapp.formAttributeDefinitions}" scope="request"/>

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
                <li><a href="${bundle.kappLocation}/${form.slug}?page=form-management/forms&kapp=${currentKapp.slug}">${text.escape(currentKapp.name)}</a></li>
                <li class="active">${text.escape(currentObj.name)}</li>
            </bundle:variable>
            <!-- BREADCRUMBS END HERE. ------------------------------------------------------------------->

            <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
            
            <div class="page-header">
                <div class="row">
                    <div class="col-xs-12">
                        <h3>
                            <span>${text.escape(currentKapp.name)}</span>
                            <small>${text.escape(currentObj.name)}</small>
                            <div class="pull-right">
                                <button data-objecttype="Form" data-ajaxpath="/kapps/${currentKapp.slug}/forms/${currentObj.slug}" class="btn btn-small btn-tertiary pull-right update-object-btn">
                                    Update Form
                                </button>
                            </div>
                        </h3>
                    </div>
                </div>
            </div>
            
            <div class="row">
                <div class="col-xs-12">
                    <!-- You must pass ALL attributes you want to update, not just some
                    when updating an object. The following elements are hidden and are placeholders
                    for the attributes we don't want to expose in the UI but need to be sent with the
                    update call -->
                    <div class="hidden">
                        <c:forEach items="${attributeDefinitions}" var="attribute">
                            <div class="attribute">
                                <input class="attributeValue" name="${attribute.name}" value="${fn:escapeXml(currentObj.getAttributeValue(attribute.name))}">
                            </div>
                        </c:forEach>
                    </div>

                    <!-- DISPLAY OPTIONS -->
                    <div class="panel panel-primary">
                        <div class="panel-heading">${i18n.translate('Display Options')}</div>
                        <div class="panel-body">

                            <!-- Build up Requested For Selector-->
                            <c:forEach items="${attributeDefinitions}" var="attribute">
                                <c:if test="${fn:containsIgnoreCase(attribute.name, 'Request For Others')}">
                                    <c:set scope="request" var="thisAttribute" value="${attribute}"/>
                                    <c:import url="${bundle.path}/partials/shared-management/request-for-others-selector.jsp" charEncoding="UTF-8" />
                                </c:if>
                            </c:forEach>

                            <!-- Build up Description Input-->
                            <div class="formDescription m-b-2">
                                <label class="control-label">${i18n.translate("Form Description")}</label>
                                <span id="helpBlock-formDescription" class="help-block">${i18n.translate("The Form Description helps users find the form they're looking for.")}</span>
                                <textarea aria-describedby="helpBlock-formDescription" type="text" name="${currentObj.description}" class="form-control" value="${currentObj.description}">${currentObj.description}</textarea>
                            </div>

                            <!-- Build up Icon Selector-->
                            <c:forEach items="${attributeDefinitions}" var="attribute">
                                <c:if test="${fn:containsIgnoreCase(attribute.name, 'Icon')}">
                                    <c:set scope="request" var="thisAttribute" value="${attribute}"/>
                                    <c:import url="${bundle.path}/partials/shared-management/icon-selector.jsp" charEncoding="UTF-8" />
                                </c:if>
                            </c:forEach>

                            <!-- Build up Team Selector -->
                            <c:forEach items="${attributeDefinitions}" var="attribute">
                                <c:if test="${fn:containsIgnoreCase(attribute.name, 'Owning Team')}">
                                    <c:set scope="request" var="thisAttribute" value="${attribute}"/>
                                    <c:import url="${bundle.path}/partials/shared-management/team-selector.jsp" charEncoding="UTF-8" />
                                </c:if>
                            </c:forEach>

                        </div>
                    </div>


                    <!-- WORKFLOW OPTIONS -->
                    <div class="panel panel-info">
                        <div class="panel-heading">${i18n.translate('Workflow Options')}</div>
                        <div class="panel-body">

                            <!-- Build up Days Due Selector-->
                            <c:forEach items="${attributeDefinitions}" var="attribute">
                                <c:if test="${fn:containsIgnoreCase(attribute.name, 'Days Due')}">
                                    <c:set scope="request" var="thisAttribute" value="${attribute}"/>
                                    <c:import url="${bundle.path}/partials/shared-management/daysdue-selector.jsp" charEncoding="UTF-8" />
                                </c:if>
                            </c:forEach>

                            <!-- Build up Team Selector -->
                            <c:forEach items="${attributeDefinitions}" var="attribute">
                                <c:if test="${fn:containsIgnoreCase(attribute.name, 'Assignee Team')}">
                                    <c:set scope="request" var="thisAttribute" value="${attribute}"/>
                                    <c:import url="${bundle.path}/partials/shared-management/team-selector.jsp" charEncoding="UTF-8" />
                                </c:if>
                            </c:forEach>

                            <!-- Build up Team Assignee Individual Selector -->
                            <c:forEach items="${attributeDefinitions}" var="attribute">
                                <c:if test="${fn:containsIgnoreCase(attribute.name, 'Assignee Individual')}">
                                    <c:set scope="request" var="thisAttribute" value="${attribute}"/>
                                    <c:import url="${bundle.path}/partials/shared-management/team-assignee-selector.jsp" charEncoding="UTF-8" />
                                </c:if>
                            </c:forEach>

                            <!-- Build up Approver Selector -->
                            <c:forEach items="${attributeDefinitions}" var="attribute">
                                <c:if test="${fn:containsIgnoreCase(attribute.name, 'Approver')}">
                                    <c:set scope="request" var="thisAttribute" value="${attribute}"/>
                                    <c:import url="${bundle.path}/partials/shared-management/approver-selector.jsp" charEncoding="UTF-8" />
                                </c:if>
                            </c:forEach>

                            <!-- Build up Form Selector -->
                            <c:forEach items="${attributeDefinitions}" var="attribute">
                                <c:if test="${fn:containsIgnoreCase(attribute.name, 'Form Slug')}">
                                    <c:set scope="request" var="thisAttribute" value="${attribute}"/>
                                    <c:import url="${bundle.path}/partials/shared-management/form-selector.jsp" charEncoding="UTF-8" />
                                </c:if>
                            </c:forEach>

                            <!-- Build up Notification Selector -->
                            <c:forEach items="${attributeDefinitions}" var="attribute">
                                <c:if test="${fn:containsIgnoreCase(attribute.name, 'Notification Template Name')}">
                                    <c:set scope="request" var="thisAttribute" value="${attribute}"/>
                                    <c:import url="${bundle.path}/partials/shared-management/notification-selector.jsp" charEncoding="UTF-8" />
                                </c:if>
                            </c:forEach>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
    
            <!-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -------------------------------->
            <bundle:variable name="aside">
                <h3>${form.name}</h3>
                <h4>
                    <span><a href="${bundle.kappLocation}/${form.slug}?page=form-management/forms&kapp=${currentKapp.slug}">${text.escape(currentKapp.name)}</a> > </span>
                    <small>${text.escape(currentObj.name)}</small>
                </h4>
                <hr class="border-color-white" />
                <p>
                    Here you can find modify different properties for this form including Workflow Options, Categorizations and the forms Description.
                </p>
                <p>
                    They system was designed to be hierarchical so that properties configured at the form level (this level) override properties set at the Kapp and Space level. Properties configured here will be used within the workflow rules and will ignore settings configured at the Kapp and Space level. If routing rules are not configured here, rules set at the Kapp or Space level will be used.
                </p>
                <hr class="border-color-white" />
                <h4>
                    Form Builder
                </h4>
                <p>
                    You can modify the fields on this form by opening the <span class="strong">Kinetic Request</span> Management Console.
                </p>
                <a target="_blank" href="${bundle.spaceLocation}/app/#/${currentKapp.slug}/author/form/${currentObj.slug}/builder" class="btn btn-block btn-default">
                    <span class="glyphicon glyphicon-cog pull-left" aria-hidden="true"></span> Kinetic Request
                </a>
                <p/>
            </bundle:variable>
            <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
            
        </bundle:layout>
        
    </c:otherwise>
</c:choose>