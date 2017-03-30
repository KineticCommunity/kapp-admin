<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../../bundle/initialization.jspf" %>

<c:set var="console" value="${form}" scope="request"/>
<c:set var="currentSpace" value="${space}" scope="request"/>

<c:set var="currentObj" value="${currentSpace}" scope="request"/>
<c:set var="attributeDefinitions" value="${currentSpace.spaceAttributeDefinitions}" scope="request"/>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <!-- Sets title and imports js and css specific to this console. -->
    <bundle:variable name="head">
        <c:import url="${bundle.path}/partials/management/head.jsp" charEncoding="UTF-8"/>
    </bundle:variable>

    
    <!-- BREADCRUMBS START HERE. Remove if not needed. ------------------------------------------->
    <bundle:variable name="breadcrumb">
        <li><a href="${bundle.kappLocation}/${console.slug}">Management</a></li>
        <li class="active">Space Configuration</li>
    </bundle:variable>
    <!-- BREADCRUMBS END HERE. ------------------------------------------------------------------->

    <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
    
    <div class="page-header">
        <div class="row">
            <div class="col-xs-12">
                <h3>
                    <span>${text.escape(currentSpace.name)}</span>
                    <small>Space Configuration</small>
                </h3>
            </div>
        </div>
    </div>
                    
    <div class="row">
        <div class="col-xs-12">

            <!-- You must pass ALL attributes you want to update, not just some
            when updating a space. The following elements are hidden and are placeholders
            for the attributes we don't want to expose in the UI but need to be sent with the
            update call -->
            <div class="hidden">
                <c:forEach items="${attributeDefinitions}" var="attribute">
                    <div class="attribute">
                        <label class="control-label">${i18n.translate(attribute.name)}</label>
                        <c:if test="${not attribute.isAllowsMultiple()}">
                            <input class="attributeValue" name="${attribute.name}" value="${fn:escapeXml(currentSpace.getAttributeValue(attribute.name))}">
                        </c:if>
                        <c:if test="${attribute.isAllowsMultiple()}">
                            <select class="attributeValues" name="${attribute.name}" multiple="multiple">
                                <c:forEach var="value" items="${currentSpace.getAttributeValues(attribute.name)}">
                                    <option selected value="${fn:escapeXml(value)}">${value}</option>
                                </c:forEach>
                            </select>                            
                        </c:if>
                    </div>
                </c:forEach>
            </div>
            
            <!-- THEMING OPTIONS -->
            <div class="panel panel-primary">
                <div class="panel-heading">${i18n.translate('Theming Options')}</div>
                <div class="panel-body">

                    <!-- Build up Company Name Attribute-->
                    <c:forEach items="${attributeDefinitions}" var="attribute">
                        <c:if test="${fn:containsIgnoreCase(attribute.name, 'Company Name')}">
                            <c:set scope="request" var="thisAttribute" value="${attribute}"/>
                            <c:import url="${bundle.path}/partials/management/plaintext-input.jsp" charEncoding="UTF-8" />
                        </c:if>
                    </c:forEach>

                    <!-- Build up Color Attributes-->
                    <c:forEach items="${attributeDefinitions}" var="attribute">
                        <c:if test="${fn:containsIgnoreCase(attribute.name, 'Color')}">
                            <c:set scope="request" var="thisAttribute" value="${attribute}"/>
                            <c:import url="${bundle.path}/partials/management/color-selector.jsp" charEncoding="UTF-8" />
                        </c:if>
                    </c:forEach>

                    <!-- Build up Background Image Attributes-->
                    <c:forEach items="${attributeDefinitions}" var="attribute">
                        <c:if test="${fn:containsIgnoreCase(attribute.name, 'Background Image')}">
                            <c:set scope="request" var="thisAttribute" value="${attribute}"/>
                            <c:import url="${bundle.path}/partials/management/background-selector.jsp" charEncoding="UTF-8" />
                        </c:if>
                    </c:forEach>

                    <div class="row">
                        <div class="col-md-4">
                            <!-- Build up Public User Attribute Definitions-->
                            <c:forEach items="${attributeDefinitions}" var="attribute">
                                <c:if test="${fn:containsIgnoreCase(attribute.name, 'Public User Attributes')}">
                                    <c:set scope="request" var="thisAttribute" value="${attribute}"/>
                                    <c:set scope="request" var="attributeDefs" value="${currentSpace.userAttributeDefinitions}"/>
                                    <c:import url="${bundle.path}/partials/management/multiple-attributes-checkbox-selector.jsp" charEncoding="UTF-8" />
                                </c:if>
                            </c:forEach>
                        </div>
                        <div class="col-md-4">
                            <!-- Build up Public User Profile Attribute Definitions-->
                            <c:forEach items="${attributeDefinitions}" var="attribute">
                                <c:if test="${fn:containsIgnoreCase(attribute.name, 'Public User Profile Attributes')}">
                                    <c:set scope="request" var="thisAttribute" value="${attribute}"/>
                                    <c:set scope="request" var="attributeDefs" value="${currentSpace.userProfileAttributeDefinitions}"/>
                                    <c:import url="${bundle.path}/partials/management/multiple-attributes-checkbox-selector.jsp" charEncoding="UTF-8" />
                                </c:if>
                            </c:forEach>
                        </div>
                        <div class="col-md-4">
                            <!-- Build up Public Team Attribute Definitions-->
                            <c:forEach items="${attributeDefinitions}" var="attribute">
                                <c:if test="${fn:containsIgnoreCase(attribute.name, 'Public Team Attributes')}">
                                    <c:set scope="request" var="thisAttribute" value="${attribute}"/>
                                    <c:set scope="request" var="attributeDefs" value="${currentSpace.teamAttributeDefinitions}"/>
                                    <c:import url="${bundle.path}/partials/management/multiple-attributes-checkbox-selector.jsp" charEncoding="UTF-8" />
                                </c:if>
                            </c:forEach>
                        </div>
                    </div>
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
                            <c:import url="${bundle.path}/partials/management/daysdue-selector.jsp" charEncoding="UTF-8" />
                        </c:if>
                    </c:forEach>

                    <!-- Build up Team Selector -->
                    <c:forEach items="${attributeDefinitions}" var="attribute">
                        <c:if test="${fn:containsIgnoreCase(attribute.name, 'Assignee Team')}">
                            <c:set scope="request" var="thisAttribute" value="${attribute}"/>
                            <c:import url="${bundle.path}/partials/management/team-selector.jsp" charEncoding="UTF-8" />
                        </c:if>
                    </c:forEach>

                    <!-- Build up Approver Selector -->
                    <c:forEach items="${attributeDefinitions}" var="attribute">
                        <c:if test="${fn:containsIgnoreCase(attribute.name, 'Approver')}">
                            <c:set scope="request" var="thisAttribute" value="${attribute}"/>
                            <c:import url="${bundle.path}/partials/management/approver-selector.jsp" charEncoding="UTF-8" />
                        </c:if>
                    </c:forEach>

                    <!-- Build up Form Selector -->
                    <c:forEach items="${attributeDefinitions}" var="attribute">
                        <c:if test="${fn:containsIgnoreCase(attribute.name, 'Form Slug')}">
                            <c:set scope="request" var="thisAttribute" value="${attribute}"/>
                            <c:import url="${bundle.path}/partials/management/form-selector.jsp" charEncoding="UTF-8" />
                        </c:if>
                    </c:forEach>
                </div>
            </div>
                
            <div class="row m-b-2">
                <div class="col-xs-12">
                    <div class="form-buttons pull-right">
                        <button data-objecttype="Form" data-ajaxpath="/space" class="btn btn-success update-object-btn">
                            <span class="fa fa-check fa-fw"></span>
                            <span>Update Space</span>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -------------------------------->
    <bundle:variable name="aside">
        <h3>${form.name}</h3>
        <p>${form.description}</p>
        <hr class="border-color-white" />
        <p>
            Theming options drive overall look and feel of the system. Primary and Secondary colors should be HEX values (ex #000000). The Background Image should be either an internet accessable url to an image, or the path to an image in your environments web bundle.
        </p>
        <p>
            Workflow Options at the Space Level will typically be overridden by Options (attributes) set within a specific form or Kapp.
        </p>
        <hr class="border-color-white" />
        <h4>
            Advanced Management
        </h4>
        <p>
            The <span class="strong">Kinetic Request</span> Management Console is for advanced configuration of portals and forms. Most common configurations can be made using this Admin Console.
        </p>
        <a target="_blank" href="${bundle.spaceLocation}/app/#/admin/space/details" class="btn btn-block btn-default">
            <span class="glyphicon glyphicon-cog pull-left" aria-hidden="true"></span> Kinetic Request
        </a>
        <p/>
    </bundle:variable>
    <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
    
</bundle:layout>