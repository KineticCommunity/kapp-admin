<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<%@include file="../../bundle/router.jspf" %>

<!-- Set Varibles Needed To Build DOM Elements -->
<c:set var="groupList" value="${GroupHelper.getGroupsFlattened()}" scope="request"/>
<c:set var="attributeDefinitions" value="${space.spaceAttributeDefinitions}" scope="request"/>
<c:set var="currentObj" value="${space}" scope="request"/>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <!-- Sets title and imports js and css specific to this console. -->
    <bundle:variable name="head">
        <c:import url="${bundle.path}/partials/space-management/head.jsp" charEncoding="UTF-8"/>
    </bundle:variable>

    
    <!-- BREADCRUMBS START HERE. Remove if not needed. ------------------------------------------->
    <bundle:variable name="breadcrumb">
        <li class="active">${space.name}</li>
    </bundle:variable>
    <!-- BREADCRUMBS END HERE. ------------------------------------------------------------------->

    <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
    
    <div class="page-header">
        <div class="row">
            <div class="col-xs-12">
                <h3>
                    <span>${form.name}</span>
                    <div class="pull-right">
                        <button data-objecttype="Form" data-ajaxpath="/space" class="btn btn-small btn-success pull-right update-object-btn">
                            Update Space
                        </button>
                    </div>
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
                        <input class="attributeValue" name="${attribute.name}" value="${space.getAttributeValue(attribute.name)}">
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
                            <c:import url="${bundle.path}/partials/shared-management/plaintext-input.jsp" charEncoding="UTF-8" />
                        </c:if>
                    </c:forEach>

                    <!-- Build up Color Attributes-->
                    <c:forEach items="${attributeDefinitions}" var="attribute">
                        <c:if test="${fn:containsIgnoreCase(attribute.name, 'Color')}">
                            <c:set scope="request" var="thisAttribute" value="${attribute}"/>
                            <c:import url="${bundle.path}/partials/shared-management/color-selector.jsp" charEncoding="UTF-8" />
                        </c:if>
                    </c:forEach>

                    <!-- Build up Background Image Attributes-->
                    <c:forEach items="${attributeDefinitions}" var="attribute">
                        <c:if test="${fn:containsIgnoreCase(attribute.name, 'Background Image')}">
                            <c:set scope="request" var="thisAttribute" value="${attribute}"/>
                            <c:import url="${bundle.path}/partials/shared-management/plaintext-input.jsp" charEncoding="UTF-8" />
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
                </div>
            </div>

        </div>
    </div>

    <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
    
    <!-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -------------------------------->
    <bundle:variable name="aside">
        <h3>${form.name}</h3>
        <p>${form.description}</p>
        <hr class="border-color-white" />
        <p>Theming options drive overall look and feel of the system. Primary and Secondary colors should be HEX values (ex #000000). The Background Image should be either an internet accessable url to an image, or the path to an image in your environments web bundle.</p>
        <p>Workflow Options at the Space Level will typically be overridden by Options (attributes) set within a specific form or Kapp.</p>
    </bundle:variable>
    <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
    
</bundle:layout>