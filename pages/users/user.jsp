<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<c:set var="isNew" value="${empty param.username}" />
<c:set var="isClone" value="${isNew && not empty param.clone}" />
<c:set var="currentUser" value="${isClone ? space.getUser(param.clone) : space.getUser(param.username)}" />

<c:choose>
    <c:when test="${not isNew && empty currentUser}">
        <c:set var="error" value="${i18n.translate('User USERNAME does not exist.')
            .replace('USERNAME', '<b>USERNAME</b>')
            .replace('USERNAME', param.username)}" />
    </c:when>
    <c:when test="${isClone && empty currentUser}">
        <c:set var="error" value="${i18n.translate('User USERNAME, who you are trying to clone, does not exist.')
            .replace('USERNAME', '<b>USERNAME</b>')
            .replace('USERNAME', param.clone)}" />
    </c:when>
</c:choose>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <%-- Sets title and imports js and css specific to this console. --%>
    <bundle:variable name="head">
        <c:import url="${bundle.path}/partials/users/head.jsp" charEncoding="UTF-8"/>
    </bundle:variable>
    
    <%-- BREADCRUMBS START HERE. Remove if not needed. ------------------------------------------%>
    <bundle:variable name="breadcrumb">
        <li><a href="${bundle.kappLocation}/${form.slug}">${form.name}</a></li>
        <li class="active">${not empty param.username ? param.username : (not empty param.clone ? i18n.translate('Clone User') : i18n.translate('New User'))}</li>
    </bundle:variable>
    <%-- BREADCRUMBS END HERE. ------------------------------------------------------------------%>
    
    <c:choose>
        <c:when test="${empty error}">

            <%-- PAGE CONTENT STARTS HERE -------------------------------------------------------%>

            <div class="page-header">
                <h2>
                    ${not isNew ? currentUser.username : (isClone ? i18n.translate('Clone User') : i18n.translate('New User'))}
                    <c:if test="${isClone}"><small> ${currentUser.username}</small></c:if>
                </h2>
            </div>
        
            <div class="user-image">
                ${GravatarHelper.get(currentUser.email, 188)}
            </div>
            
            <div class="user-details">
            
                <%-- Username: shown for new users only --%>
                <c:if test="${isNew}">
                    <div>
                        <label class="field-label required">${i18n.translate('Username')}</label>
                        <input id="user-username" type="text" class="form-control" />
                    </div>
                </c:if>
                
                <%-- Enabled and Space Admin flags --%>
                <div class="m-t-1">
                    <span class="checkbox-label">
                        <input id="user-enabled" name="user-enabled" type="checkbox" 
                               ${empty currentUser || currentUser.enabled ? 'checked ' : ''}>
                        <label class="label label-default" for="user-enabled">
                            <span>${i18n.translate('Enabled')}</span>
                        </label>
                    </span>
                    <span class="checkbox-label">
                        <input id="user-space-admin" name="user-space-admin" type="checkbox" 
                               ${currentUser.spaceAdmin ? 'checked ' : ''}>
                        <label class="label label-default" for="user-space-admin">
                            <span>${i18n.translate('Space Admin')}</span>
                        </label>
                    </span>
                </div>
            
                <%-- Display name --%>
                <div>
                    <label class="field-label">${i18n.translate('Display Name')}</label>
                    <input id="user-display-name" type="text" class="form-control" value="${not isClone ? currentUser.displayName : ''}" />
                </div>
                
                <%-- Email --%>
                <div>
                    <label class="field-label">${i18n.translate('Email')}</label>
                    <input id="user-email" type="text" class="form-control" value="${not isClone ? currentUser.email : ''}" />
                </div>
                
                <%-- Preferred Language --%>
                <div>
                    <label class="field-label">${i18n.translate('Preferred Language')}</label>
                    <select id="user-preferred-locale" class="form-control input-sm">
                        <option></option>
                        <c:forEach var="optionLocale" items="${i18n.getSystemLocales(pageContext.request.locales)}">
                            <option value="${i18n.getLocaleCode(optionLocale)}"
                                    ${i18n.getLocaleCode(optionLocale) eq (not empty currentUser 
                                        ? currentUser.preferredLocale : cloneUser.preferredLocale) ? 'selected' : ''}
                                >${text.escape(i18n.getLocaleNameGlobalized(optionLocale))}</option>
                        </c:forEach>
                    </select>
                </div>
                
            </div>
            
            <%-- Profile Attributes --%>
            <div class="user-profile-attributes">
                <c:forEach var="profileAttributeDefinition" items="${TeamsHelper.getOrderedUserProfileAttributeDefinitions()}">
                    <c:if test="${empty firstProfileAttribute}">
                        <h4 class="m-t-4">${i18n.translate('Profile Attributes')}</h4>
                        <c:set var="firstProfileAttribute" value="${true}" />
                    </c:if>
                    
                    <div data-profile-attribute="${profileAttributeDefinition.name}" 
                         data-allows-multiple="${profileAttributeDefinition.allowsMultiple}">
                        <label class="field-label">
                            <span>${i18n.translate(profileAttributeDefinition.name)}</span>
                            <c:if test="${profileAttributeDefinition.allowsMultiple}">
                                <small>
                                    <a href="javascript:void(0);" class="falink add-attribute-row">
                                        <span class="fa fa-plus fa-fw"></span>
                                    </a>
                                </small>
                            </c:if>
                            <i class="small">${profileAttributeDefinition.description}</i>
                        </label>
                        <c:choose>
                            <c:when test="${text.equals(profileAttributeDefinition.name, 'Email Notifications')}">
                                <%-- If "Email Notifications" attribute, show as radio buttons --%>
                                <c:set var="emailNotifications" value="${currentUser.getProfileAttributeValue(profileAttributeDefinition.name) ne 'No'}" />
                                <label for="email-notification-yes" class="display-inline-block m-r-2">
                                    <input type="radio" name="email-notification" value="Yes" id="email-notification-yes"
                                           ${emailNotifications ? 'checked' : ''} />
                                    <span>Yes</span>
                                </label>
                                <label for="email-notification-no" class="display-inline-block m-r-2">
                                    <input type="radio" name="email-notification" value="No" id="email-notification-no"
                                           ${!emailNotifications ? 'checked' : ''} />
                                    <span>No</span>
                                </label>
                            </c:when>
                            <c:otherwise>
                                <%-- For all other profile attributes, show as input box(es) --%>
                                <c:forEach var="profileAttributeValue" items="${currentUser.getProfileAttributeValues(profileAttributeDefinition.name)}">
                                    <input type="text" class="form-control" value="${profileAttributeValue}" />
                                </c:forEach>
                                <c:if test="${not currentUser.hasProfileAttribute(profileAttributeDefinition.name)}">
                                    <input type="text" class="form-control" />
                                </c:if>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </c:forEach>
            </div>
            
            <%-- User Attributes --%>
            <div class="user-attributes">
                <c:forEach var="userAttributeDefinition" items="${TeamsHelper.getOrderedUserAttributeDefinitions()}">
                    <c:if test="${empty firstUserAttribute}">
                        <h4 class="m-t-4">${i18n.translate('User Attributes')}</h4>
                        <c:set var="firstUserAttribute" value="${true}" />
                    </c:if>
                    <div data-user-attribute="${userAttributeDefinition.name}" 
                         data-allows-multiple="${userAttributeDefinition.allowsMultiple}">
                        <label class="field-label">
                            <span>${i18n.translate(userAttributeDefinition.name)}</span>
                            <c:if test="${userAttributeDefinition.allowsMultiple}">
                                <small>
                                    <a href="javascript:void(0);" class="falink add-attribute-row">
                                        <span class="fa fa-plus fa-fw"></span>
                                    </a>
                                </small>
                            </c:if>
                            <i class="small">${userAttributeDefinition.description}</i>
                        </label>
                        <%-- For all user attributes, show as input box(es) --%>
                        <c:forEach var="userAttributeValue" items="${currentUser.getAttributeValues(userAttributeDefinition.name)}">
                            <input type="text" class="form-control" value="${userAttributeValue}" />
                        </c:forEach>
                        <c:if test="${not currentUser.hasAttribute(userAttributeDefinition.name)}">
                            <input type="text" class="form-control" />
                        </c:if>
                    </div>
                </c:forEach>
            </div>
            
            <%-- User Roles --%>
            <c:if test="${not empty TeamsHelper.getRoles()}">
                <div class="user-roles">
                    <h4 class="m-t-4">${i18n.translate('Roles')}</h4>
                    <div class="row">
                        <c:forEach var="role" items="${TeamsHelper.getRoles()}">
                            <div class="col-xs-12 col-sm-6">
                                <span class="checkbox-label">
                                    <input id="role_${role.slug}" type="checkbox" value="${role.name}"
                                           ${TeamsHelper.isMemberOfTeam(currentUser, role.team) ? 'checked' : ''}>
                                    <label class="label label-default" for="role_${role.slug}">
                                        <span>${i18n.translate(role.formattedName)}</span>
                                    </label>
                                </span>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </c:if>

            <%-- User Teams --%>
            <c:if test="${not empty TeamsHelper.getTeams()}">
                <div class="user-teams">
                    <h4 class="m-t-4">${i18n.translate('Teams')}</h4>
                    <c:forEach var="team" items="${TeamsHelper.getUserTeams(currentUser)}">
                        <div class="team-label" data-team-slug="${team.slug}" data-team-name="${team.name}" >
                            <label class="label label-primary">
                                <span class="fa fa-fw ${team.icon}"></span>
                                <span>${i18n.translate(team.name)}</span>
                                <span class="badge"><span class="fa fa-times"></span></span>
                            </label>
                        </div>
                    </c:forEach>
                    <div class="input-group add-team">
                        <span class="input-group-addon">Add to Team</span>
                        <select id="available-teams" class="form-control">
                            <option />
                            <c:forEach var="team" items="${TeamsHelper.getTeams()}">
                                <c:if test="${!TeamsHelper.isMemberOfTeam(currentUser, team.team)}">
                                    <option data-team-slug="${team.slug}" data-team-icon="${team.icon}" 
                                            value="${team.name}">${i18n.translate(team.name)}</option>
                                </c:if>
                            </c:forEach>
                        </select>
                        <select id="source-teams" class="form-control hide">
                            <option />
                            <c:forEach var="team" items="${TeamsHelper.getTeams()}">
                                <option data-team-slug="${team.slug}" data-team-icon="${team.icon}" 
                                        value="${team.name}">${i18n.translate(team.name)}</option>
                            </c:forEach>
                        </select>
                        <span class="input-group-btn">
                            <button class="btn btn-tertiary" type="button">
                                <span class="fa fa-plus fa-fw"></span>
                            </button>
                        </span>
                    </div>
                </div>
                <div class="team-label-template hide">
                    <div class="team-label" data-team-slug="{{teamSlug}}" data-team-name="{{teamName}}" >
                        <label class="label label-primary">
                            <span class="fa fa-fw {{teamIcon}}"></span>
                            <span>{{teamDisplayName}}</span>
                            <span class="badge"><span class="fa fa-times"></span></span>
                        </label>
                    </div>
                </div>
            </c:if>
            
            <%-- Actions buttons when editing a user (save, cancel, and delete) --%>
            <div class="m-y-4 text-right">
                <c:if test="${not isNew}">
                    <button class="btn btn-link danger delete-user pull-left">Delete User</button>
                </c:if>
                
                <button class="btn btn-success save-user">Save User</button>
                <a href="${bundle.kappLocation}/${form.slug}" class="btn btn-link">Cancel</a>
                
            </div>
    
            <%-- PAGE CONTENT ENDS HERE ---------------------------------------------------------%>
    
            <%-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -----------------------%>
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
            <%-- RIGHT SIDEBAR CONTENT ENDS HERE. -----------------------------------------------%>
            
        </c:when>
        <c:otherwise>
            <c:import url="${bundle.path}/partials/error.jsp" charEncoding="UTF-8">
                <c:param name="message" value="${error}"/>
            </c:import>
        </c:otherwise>
    </c:choose>

</bundle:layout>