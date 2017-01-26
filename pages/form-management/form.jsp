<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<c:set var="currentKapp" value="${space.getKapp(param.kapp)}" scope="request"/>
<c:set var="currentForm" value="${space.getKapp(param.kapp).getForm(param.form)}" scope="request"/>

<!-- Set Variable to hold Space Attributes so we don't have to get them multiple times -->
<c:set var="formAttributeDefinitions" value="${currentKapp.formAttributeDefinitions}"/>
<c:set var="groupList" value="${GroupHelper.getGroupsFlattened()}" scope="request"/>

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
                <li><a href="${bundle.kappLocation}/${form.slug}/?page=form-management/forms&kapp=${currentKapp.slug}">${text.escape(currentKapp.name)}</a></li>
                <li class="active">${text.escape(currentForm.name)}</li>
            </bundle:variable>
            <!-- BREADCRUMBS END HERE. ------------------------------------------------------------------->

            <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
            
            <div class="page-header">
                <div class="row">
                    <div class="col-xs-12">
                        <h3>
                            <span>${text.escape(currentKapp.name)}</span>
                            <small>${text.escape(currentForm.name)}</small>
                            <div class="pull-right">
                                <button class="hidden btn btn-small btn-success pull-right update-system-btn">
                                    Update Form
                                </button>
                            </div>
                        </h3>
                    </div>
                </div>
            </div>
            
            <div class="row">
                <div class="col-xs-12">
                    <!-- WORKFLOW OPTIONS -->
                    <div class="panel panel-info">
                        <div class="panel-heading">${i18n.translate('Workflow Options')}</div>
                        <div class="panel-body">
                            <!-- Build up Days Due Attributes-->
                            <c:forEach items="${formAttributeDefinitions}" var="attribute">
                                <c:if test="${fn:containsIgnoreCase(attribute.name, 'Days Due')}">
                                
                                    <div class="m-b-2">
                                        <label class="control-label">${i18n.translate(attribute.name)}</label>
                                        <span id="helpBlock-${attribute.name}" class="help-block">${currentKapp.getFormAttributeDefinition(attribute.name).description}</span>
                                        <input aria-describedby="helpBlock-${attribute.name}" type="text" name="${attribute.name}" class="spinner" value="${currentForm.getAttributeValue(attribute.name)}">
                                    </div>
                                </c:if>
                            </c:forEach>

                            <!-- Build up Group Dropdown Attributes-->
                            <c:forEach items="${formAttributeDefinitions}" var="attribute">
                                <c:if test="${fn:containsIgnoreCase(attribute.name, 'Assignee Group')}">
                                    <div class="m-b-2">
                                        <label class="control-label">${i18n.translate(attribute.name)}</label>
                                        <span id="helpBlock-${attribute.name}" class="help-block">${currentKapp.getFormAttributeDefinition(attribute.name).description}</span>
                                        <select name="${attribute.name}" class="form-control" value="${currentForm.getAttributeValue(attribute.name)}">
                                            <option/>
                                            <c:forEach items="${groupList}" var="group">
                                                <c:set var="selected" value=""/>
                                                <c:if test="${group.name eq currentForm.getAttributeValue(attribute.name)}">
                                                    <c:set var="selected" value="selected"/>
                                                </c:if>
                                                <option ${selected} value="${group.name}">${group.name}</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                </c:if>
                            </c:forEach>

                            <!-- Build up Group Dropdown Attributes-->
                            <c:forEach items="${formAttributeDefinitions}" var="attribute">
                                <c:if test="${fn:containsIgnoreCase(attribute.name, 'Approver')}">
                                    <div class="m-b-2">
                                        <label class="control-label">${i18n.translate(attribute.name)}</label>
                                        <span id="helpBlock-${attribute.name}" class="help-block">${currentKapp.getFormAttributeDefinition(attribute.name).description}</span>
                                        <label class="radio-inline"><input type="radio" name="optManager">Manager</label>
                                        <label class="radio-inline"><input type="radio" name="optGroup">Group</label>
                                        <label class="radio-inline"><input type="radio" name="optIndividual">Individual</label>
                                        <input name="${attribute.name}" style="display:none;" class="form-control" value="${currentForm.getAttributeValue(attribute.name)}">

                                        <select name="${attribute.name}" style="display:none;" class="form-control" value="${currentForm.getAttributeValue(attribute.name)}">
                                            <option/>
                                            <c:forEach items="${groupList}" var="group">
                                                <c:set var="selected" value=""/>
                                                <c:if test="${group.name eq currentForm.getAttributeValue(attribute.name)}">
                                                    <c:set var="selected" value="selected"/>
                                                </c:if>
                                                <option ${selected} value="${group.name}">${group.name}</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                </c:if>
                            </c:forEach>

                            <!-- Build up Form Slug Attributes-->
                            <c:forEach items="${formAttributeDefinitions}" var="attribute">
                                <c:if test="${fn:containsIgnoreCase(attribute.name, 'Form Slug')}">
                                    <div class="m-b-2">
                                        <label class="control-label">Default ${i18n.translate(fn:substringBefore(attribute.name, 'Slug'))} Name</label>
                                        <span id="helpBlock-${attribute.name}" class="help-block">${currentKapp.getFormAttributeDefinition(attribute.name).description}</span>
                                        <select name="${attribute.name}" class="form-control" value="${currentForm.getAttributeValue(attribute.name)}">
                                            <option/>
                                            <c:forEach items="${space.getKapp(currentForm.getAttributeValue('Queue Kapp Slug')).forms}" var="form">
                                                <c:set var="selected" value=""/>
                                                <c:if test="${form.slug eq currentForm.getAttributeValue(attribute.name)}">
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
            
            <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
    
            <!-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -------------------------------->
            <bundle:variable name="aside">
                <h3>${form.name}</h3>
                <h4>${currentKapp.name}</h4>
                <hr class="border-color-white" />
                <p>To add a new root category, click the <b class="nowrap"><span class="fa fa-plus"></span> Add Category</b> button.</p>
                <p>To update a category, select a category by clicking on it.</p>
                <p>To add a subcategory to a selected category, click the <b class="nowrap"><span class="fa fa-plus"></span> Add Subcategory</b> button.</p>
                <p>You can drag categories to sort them and reorganize the hierarchy.</p>
            </bundle:variable>
            <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
            
        </bundle:layout>
        
    </c:otherwise>
</c:choose>