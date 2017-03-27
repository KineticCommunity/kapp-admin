<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<c:choose>
    <c:when test="${text.isNotBlank(param.username)}">
        <c:catch var="userNotFound">
            <bundle:request method="get"
                            url="${bundle.apiPath}/users/${text.escape(param.username)}?include=attributes%2CprofileAttributes"
                            var="user"
                            scope="request" />
            <c:set var="currentUser" value="${not empty user ? json.parse(user).user : null}" scope="request" />
        </c:catch>
    </c:when>
    <c:when test="${text.isNotBlank(param.clone)}">
        <c:catch var="cloneNotFound">
            <bundle:request method="get"
                            url="${bundle.apiPath}/users/${text.escape(param.clone)}?include=attributes%2CprofileAttributes"
                            var="clone"
                            scope="request" />
            <c:set var="cloneUser" value="${not empty clone ? json.parse(clone).user : null}" scope="request" />
        </c:catch>
    </c:when>
</c:choose>
<c:set var="groupList" value="${GroupHelper.getGroupsFlattened()}" scope="request"/>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <!-- Sets title and imports js and css specific to this console. -->
    <bundle:variable name="head">
        <c:import url="${bundle.path}/partials/users/head.jsp" charEncoding="UTF-8"/>
    </bundle:variable>
    
    <!-- BREADCRUMBS START HERE. Remove if not needed. ------------------------------------------->
    <bundle:variable name="breadcrumb">
        <li><a href="${bundle.kappLocation}/${form.slug}">${form.name}</a></li>
        <li class="active">${not empty currentUser ? currentUser.username : (not empty cloneUser ? 'Clone User' : 'New User')}</li>
    </bundle:variable>
    <!-- BREADCRUMBS END HERE. ------------------------------------------------------------------->

    <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->

    <div class="page-header">
        <h2>
            ${not empty currentUser ? currentUser.username : (not empty cloneUser ? 'Clone User' : 'New User')}
            <c:if test="${not empty cloneUser}"><small> ${cloneUser.username}</small></c:if>
        </h2>
    </div>

    <div class="row user-details">
        <c:if test="${empty currentUser}">
            <div class="col-xs-12">
                <label for="username" class="control-label required-field">${i18n.translate('Username')}</label>
                <input type="text" id="username" name="username" class="form-control" value="${param.username}">
            </div>
        </c:if>
        <div class="col-xs-12">
            <label for="displayName" class="control-label">${i18n.translate('Display Name')}</label>
            <input type="text" id="displayName" name="displayName" class="form-control" value="${currentUser.displayName}">
        </div>
        <div class="col-xs-12">
            <label for="email" class="control-label">${i18n.translate('Email')}</label>
            <input type="text" id="email" name="email" class="form-control" value="${currentUser.email}">
        </div>
        <div class="col-xs-12">
            <label for="displayName" class="control-label">${i18n.translate('Preferred Language')}</label>
            <select id="preferredLocale" name="preferredLocale" class="form-control">
                <option></option>
                <c:forEach var="optionLocale" items="${i18n.getSystemLocales(pageContext.request.locales)}">
                    <option value="${i18n.getLocaleCode(optionLocale)}" 
                            ${i18n.getLocaleCode(optionLocale) == text.defaultIfBlank(currentUser.preferredLocale, cloneUser.preferredLocale) ? 'selected' : ''}
                        >${text.escape(i18n.getLocaleNameGlobalized(optionLocale))}</option>
                </c:forEach>
            </select>
        </div>
        <div class="col-xs-6">
            <input id="enabled" name="enabled" type="checkbox" ${not empty currentUser ? (currentUser.enabled ? 'checked' : '') : (cloneUser.enabled ? 'checked' : '')}>
            <label for="enabled" class="control-label">${i18n.translate('Enabled?')}</label>
        </div>
        <div class="col-xs-6">
            <input id="spaceAdmin" name="spaceAdmin" type="checkbox" ${currentUser.spaceAdmin ? 'checked' : ''} disabled>
            <label for="spaceAdmin" class="control-label">${i18n.translate('Space Admin?')}</label>
        </div>
        <div class="col-xs-12">
            <label class="control-label">${i18n.translate('Groups')}</label>
            <table class="table table-hover" data-user-groups-table> 
                <tbody>
                    <c:forEach items="${not empty currentUser ? currentUser.attributes : cloneUser.attributes}" var="attribute">
                        <c:if test="${attribute.name eq 'Group'}">
                            <c:forEach items="${attribute.values}" var="group">
                                <tr>
                                    <td class="group-name">${group}</td>
                                    <td>
                                        <div class="btn-group pull-right">
                                            <a class="btn btn-xs btn-danger delete-group-btn" href="javascript:void(0);">
                                                <span class="fa fa-times fa-fw"></span>
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:if>
                    </c:forEach>
                </tbody>
                <tfoot>
                    <tr>
                        <td>
                            <select class="form-control add-group-name-field">
                                <option/>
                            </select>
                            <select class="add-group-name-field-options hide">
                                <c:forEach items="${groupList}" var="group">
                                    <c:if test="${}"></c:if>
                                    <option value="${group.name}">${group.name}</option>
                                </c:forEach>
                            </select>
                        </td>
                        <td>
                            <button class="btn btn-success pull-right add-group-btn">
                                <span class="fa fa-plus"></span>
                                <span>Add Group</span>
                            </button>
                        </td>
                    </tr>
                </tfoot>
                <tfoot class="template hide">
                    <tr>
                        <td class="group-name">{{group}}</td>
                        <td>
                            <div class="btn-group pull-right">
                                <a class="btn btn-xs btn-danger delete-group-btn" href="javascript:void(0);">
                                    <span class="fa fa-times fa-fw"></span>
                                </a>
                            </div>
                        </td>
                    </tr>
                </tfoot>
            </table>
        </div>
        <div class="col-xs-12">
            <label class="control-label">${i18n.translate('Attributes')}</label>
            <table class="table table-hover" data-user-attributes-table>
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>Value</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${not empty currentUser ? currentUser.attributes : cloneUser.attributes}" var="attribute">
                        <c:if test="${attribute.name ne 'Group'}">
                            <c:forEach items="${attribute.values}" var="value">
                                <tr>
                                    <td class="attribute-name">${attribute.name}</td>
                                    <td class="attribute-value">
                                        <input class="form-control" value="${value}" />
                                    </td>
                                    <td>
                                        <div class="btn-group pull-right">
                                            <a class="btn btn-xs btn-danger delete-attribute-btn" href="javascript:void(0);">
                                                <span class="fa fa-times fa-fw"></span>
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:if>
                    </c:forEach>
                </tbody>
                <tfoot>
                    <tr>
                        <td>
                            <select class="form-control add-attribute-name-field">
                                <option/>
                            </select>
                            <select class="add-attribute-name-field-options hide">
                                <c:forEach items="${space.userAttributeDefinitions}" var="attributeDefinition">
                                    <c:if test="${attributeDefinition.name ne 'Group'}">
                                        <option data-allows-multiple="${attributeDefinition.allowsMultiple}" value="${attributeDefinition.name}">${attributeDefinition.name}</option>
                                    </c:if>
                                </c:forEach>
                            </select>
                        </td>
                        <td>
                            <input class="form-control add-attribute-value-field" />
                        </td>
                        <td>
                            <button class="btn btn-success pull-right add-attribute-btn">
                                <span class="fa fa-plus"></span>
                                <span>Add Attribute</span>
                            </button>
                        </td>
                    </tr>
                </tfoot>
                <tfoot class="template hide">
                    <tr>
                        <td class="attribute-name">{{attributeName}}</td>
                        <td class="attribute-value">
                            <input class="form-control" value="{{attributeValue}}" />
                        </td>
                        <td>
                            <div class="btn-group pull-right">
                                <a class="btn btn-xs btn-danger delete-attribute-btn" href="javascript:void(0);">
                                    <span class="fa fa-times fa-fw"></span>
                                </a>
                            </div>
                        </td>
                    </tr>
                </tfoot>
            </table>
        </div>
        <div class="col-xs-12">
            <label class="control-label">${i18n.translate('Profile Attributes')}</label>
            <table class="table table-hover" data-user-profile-attributes-table>
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>Value</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${not empty currentUser ? currentUser.profileAttributes : cloneUser.profileAttributes}" var="attribute">
                        <c:forEach items="${attribute.values}" var="value">
                            <tr>
                                <td class="attribute-name">${attribute.name}</td>
                                <td class="attribute-value">
                                    <input class="form-control" value="${value}" />
                                </td>
                                <td>
                                    <div class="btn-group pull-right">
                                        <a class="btn btn-xs btn-danger delete-attribute-btn" href="javascript:void(0);">
                                            <span class="fa fa-times fa-fw"></span>
                                        </a>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:forEach>
                </tbody>
                <tfoot>
                    <tr>
                        <td>
                            <select class="form-control add-attribute-name-field">
                                <option/>
                            </select>
                            <select class="add-attribute-name-field-options hide">
                                <c:forEach items="${space.userProfileAttributeDefinitions}" var="attributeDefinition">
                                    <option data-allows-multiple="${attributeDefinition.allowsMultiple}" value="${attributeDefinition.name}">${attributeDefinition.name}</option>
                                </c:forEach>
                            </select>
                        </td>
                        <td>
                            <input class="form-control add-attribute-value-field" />
                        </td>
                        <td>
                            <button class="btn btn-success pull-right add-attribute-btn">
                                <span class="fa fa-plus"></span>
                                <span>Add Attribute</span>
                            </button>
                        </td>
                    </tr>
                </tfoot>
                <tfoot class="template hide">
                    <tr>
                        <td class="attribute-name">{{attributeName}}</td>
                        <td class="attribute-value">
                            <input class="form-control" value="{{attributeValue}}" />
                        </td>
                        <td>
                            <div class="btn-group pull-right">
                                <a class="btn btn-xs btn-danger delete-attribute-btn" href="javascript:void(0);">
                                    <span class="fa fa-times fa-fw"></span>
                                </a>
                            </div>
                        </td>
                    </tr>
                </tfoot>
            </table>
        </div>
    </div>
    <div class="row">
        <div class="col-xs-12 text-right">
            <button class="btn btn-success save-user-btn" type="button">${i18n.translate('Save User')}</button>
            <a class="btn btn-link" type="button" href="${bundle.kappLocation}/${form.slug}">${i18n.translate('Cancel')}</a>
        </div>
    </div>

    <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
    
    <!-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -------------------------------->
    <bundle:variable name="aside">
        <h3>${form.name}</h3>
        <h5>
            ${not empty currentUser ? currentUser.username : (not empty cloneUser ? 'Clone User' : 'New User')}
            <c:if test="${not empty cloneUser}"><small> ${cloneUser.username}</small></c:if>
        </h5>
        <hr class="border-color-white" />
        <p>
            Please visit Space Administration to define new 
            <a href="${bundle.spaceLocation}/app/#/admin/attributeDefinitions/User" target="_blank">User Attribute Definitions</a> and new
            <a href="${bundle.spaceLocation}/app/#/admin/attributeDefinitions/User" target="_blank">Profile Attribute Definitions</a>.
        </p>
        
    </bundle:variable>
    <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
    
</bundle:layout>