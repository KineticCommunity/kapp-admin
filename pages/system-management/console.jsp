<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<%@include file="../../bundle/router.jspf" %>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <!-- Sets title and imports js and css specific to this console. -->
    <bundle:variable name="head">
        <c:import url="${bundle.path}/partials/system-management/head.jsp" charEncoding="UTF-8"/>
    </bundle:variable>

    <c:set var="groupList" value="${GroupHelper.getGroupsFlattened()}" scope="request"/>
    
    <!-- BREADCRUMBS START HERE. Remove if not needed. ------------------------------------------->
    <bundle:variable name="breadcrumb">
        <li class="active">${form.name}</li>
    </bundle:variable>
    <!-- BREADCRUMBS END HERE. ------------------------------------------------------------------->

    <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
    
    <div class="page-header">
        <h3>
            ${text.escape(form.name)}
        </h3>
    </div>
    
    <div class="row">
        <div class="col-xs-12">
            <!-- Set Variable to hold Space Attributes so we don't have to get them multiple times -->
            <c:set var="spaceAttributeDefinitions" value="${space.spaceAttributeDefinitions}"/>

            <!-- You must pass ALL attributes you want to update, not just some
            when updating a space. The following elements are hidden and are placeholders
            for the attributes we don't want to expose in the UI but need to be sent with the
            update call -->
            <div class="hidden">
                <c:forEach items="${spaceAttributeDefinitions}" var="attribute">
                    <div class="m-b-2">
                        <input name="${attribute.name}" value="${space.getAttributeValue(attribute.name)}">
                    </div>
                </c:forEach>
            </div>
            
            <!-- THEMING OPTIONS -->
            <div class="panel panel-primary">
                <div class="panel-heading">${i18n.translate('Theming Options')}</div>
                <div class="panel-body">

                    <!-- Build up Company Name Attribute-->
                    <c:forEach items="${spaceAttributeDefinitions}" var="attribute">
                        <c:if test="${fn:containsIgnoreCase(attribute.name, 'Company Name')}">
                            <div class="m-b-2">
                                <label class="control-label">${i18n.translate(attribute.name)}</label>
                                <span id="helpBlock-${attribute.name}" class="help-block">${space.getSpaceAttributeDefinition(attribute.name).description}</span>
                                <input aria-describedby="helpBlock-${attribute.name}" type="text" name="${attribute.name}" class="form-control" value="${space.getAttributeValue(attribute.name)}">
                            </div>
                        </c:if>
                    </c:forEach>

                    <!-- Build up Color Attributes-->
                    <c:forEach items="${spaceAttributeDefinitions}" var="attribute">
                        <c:if test="${fn:containsIgnoreCase(attribute.name, 'Color')}">
                            <div class="m-b-2">
                                <label class="control-label">${i18n.translate(attribute.name)}</label>
                                <span id="helpBlock-${attribute.name}" class="help-block">${space.getSpaceAttributeDefinition(attribute.name).description}</span>
                                <div class="input-group colorpicker-component">
                                    <input aria-describedby="helpBlock-${attribute.name}" type="text" name="${attribute.name}" class="form-control" value="${space.getAttributeValue(attribute.name)}" placeholder="This should be a HEX value">
                                    <span class="input-group-addon"><i></i></span>
                                </div>
                            </div>
                        </c:if>
                    </c:forEach>

                    <!-- Build up Background Image Attributes-->
                    <c:forEach items="${spaceAttributeDefinitions}" var="attribute">
                        <c:if test="${fn:containsIgnoreCase(attribute.name, 'Background Image')}">
                            <!-- Build up Color Attributes-->
                            <div class="m-b-2">
                                <label class="control-label">${i18n.translate(attribute.name)}</label>
                                <span id="helpBlock-${attribute.name}" class="help-block">${space.getSpaceAttributeDefinition(attribute.name).description}</span>
                                <label class="btn btn-default btn-file">
                                    Browse <input name="${attribute.name}" aria-describedby="helpBlock-${attribute.name}" value="${space.getAttributeValue(attribute.name)}" type="file" class="hidden">
                                </label>
                            </div>
                        </c:if>
                    </c:forEach>
                </div>
            </div>

            <!-- WORKFLOW OPTIONS -->
            <div class="panel panel-info">
                <div class="panel-heading">${i18n.translate('Workflow Options')}</div>
                <div class="panel-body">
                    <!-- Build up Days Due Attributes-->
                    <c:forEach items="${spaceAttributeDefinitions}" var="attribute">
                        <c:if test="${fn:containsIgnoreCase(attribute.name, 'Days Due')}">
                        
                            <div class="m-b-2">
                                <label class="control-label">${i18n.translate(attribute.name)}</label>
                                <span id="helpBlock-${attribute.name}" class="help-block">${space.getSpaceAttributeDefinition(attribute.name).description}</span>
                                <input aria-describedby="helpBlock-${attribute.name}" type="text" name="${attribute.name}" class="spinner" value="${space.getAttributeValue(attribute.name)}">
                            </div>
                        </c:if>
                    </c:forEach>

                    <!-- Build up Group Dropdown Attributes-->
                    <c:forEach items="${spaceAttributeDefinitions}" var="attribute">
                        <c:if test="${fn:containsIgnoreCase(attribute.name, 'Assignee Group')}">
                            <div class="m-b-2">
                                <label class="control-label">${i18n.translate(attribute.name)}</label>
                                <span id="helpBlock-${attribute.name}" class="help-block">${space.getSpaceAttributeDefinition(attribute.name).description}</span>
                                <select name="${attribute.name}" class="form-control" value="${space.getAttributeValue(attribute.name)}">
                                    <option/>
                                    <c:forEach items="${groupList}" var="group">
                                        <c:set var="selected" value=""/>
                                        <c:if test="${group.name eq space.getAttributeValue(attribute.name)}">
                                            <c:set var="selected" value="selected"/>
                                        </c:if>
                                        <option ${selected} value="${group.name}">${group.name}</option>
                                    </c:forEach>
                                </select>
                            </div>
                        </c:if>
                    </c:forEach>

                    <!-- Build up Form Slug Attributes-->
                    <c:forEach items="${spaceAttributeDefinitions}" var="attribute">
                        <c:if test="${fn:containsIgnoreCase(attribute.name, 'Form Slug')}">
                            <div class="m-b-2">
                                <label class="control-label">Default ${i18n.translate(fn:substringBefore(attribute.name, 'Slug'))} Name</label>
                                <span id="helpBlock-${attribute.name}" class="help-block">${space.getSpaceAttributeDefinition(attribute.name).description}</span>
                                <select name="${attribute.name}" class="form-control" value="${space.getAttributeValue(attribute.name)}">
                                    <option/>
                                    <c:forEach items="${space.getKapp(space.getAttributeValue('Queue Kapp Slug')).forms}" var="form">
                                        <c:set var="selected" value=""/>
                                        <c:if test="${form.slug eq space.getAttributeValue(attribute.name)}">
                                            <c:set var="selected" value="selected"/>
                                        </c:if>
                                        <option ${selected} value="${form.slug}">${form.name}</option>
                                    </c:forEach>
                                </select>
                            </div>
                        </c:if>
                    </c:forEach>
                </div>
            </div>

        </div>
    </div>

    <div class="row">
        <div class="col-xs-12 text-right">
            <button class="btn btn-success update-system-btn" type="button">${i18n.translate('Update System')}</button>
            <a class="btn btn-link" type="button" href="${bundle.kappLocation}/${form.slug}">${i18n.translate('Cancel')}</a>
        </div>
    </div>

    <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
    
    <!-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -------------------------------->
    <bundle:variable name="aside">
        <h3>${form.name}</h3>
        <p>${form.description}</p>
        <hr class="border-color-white" />
        <p>To create a new robot, click the <b class="nowrap"><span class="fa fa-plus"></span> Create Robot</b> button.</p>
        <p>To manage a robot and its schedules or view its executions, click the edit <b><span class="fa fa-pencil"></span></b> button.</p>
    </bundle:variable>
    <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
    
</bundle:layout>