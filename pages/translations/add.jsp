<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<c:set var="i18nKapp" value="${space.getKapp(text.escape(param.slug))}" scope="request" />
<c:set var="i18nBaseUrl" value="${bundle.kappLocation}/${form.slug}" scope="request" />
<c:set var="i18nKappUrl" value="${i18nBaseUrl}?slug=${text.escape(param.slug)}" scope="request" />
<c:set var="i18nApiUrl" value="${bundle.spaceLocation}/app/apis/translations/v1/kapps/${i18nKapp.slug}" scope="request" />

<!-- Show page content only if selected Kapp exists. -->
<c:choose>
    <c:when test="${empty i18nKapp}">
        <script>window.location.replace("${i18nBaseUrl}");</script>
    </c:when>
    <c:otherwise>
        
        <!-- Get Translation Snapshot for the current Kapp -->
        <c:set scope="request" var="translationSnapshot"
               value="${translationManager.getSnapshot(i18nKapp)}" />
        <!-- Get Cached translations and calculate changes waiting to be published -->
        <c:set scope="request" var="publishedSnapshot"
               value="${translationManager.getCachedSnapshot(i18nKapp)}" />
        <c:set var="pendingChanges" 
               value="${translationManager.getChanges(i18nKapp, publishedSnapshot, translationSnapshot)}"/>
        
        <c:choose>
            <c:when test="${text.isNotBlank(param.context) && text.isNotBlank(param.key)}">
                <c:set var="contextUrlParam" value="&context=${text.escape(param.context)}"/>
                <c:set var="keyUrlParam" value="&key=${text.escape(param.key)}"/>
                <c:set var="contextBreadCrumb" value="${true}"/>
                <c:set var="keyBreadCrumb" value="${true}"/>
                <c:set var="pageTitle"
                       value="${text.truncate(text.escape(param.key), 30, '...')}"/>
            </c:when>
            <c:when test="${text.isNotBlank(param.context) && text.isNotBlank(param.locale)}">
                <c:set var="localeUrlParam" value="&locale=${text.escape(param.locale)}"/>
                <c:set var="contextUrlParam" value="&context=${text.escape(param.context)}"/>
                <c:set var="contextAndLocaleBreadCrumb" value="${true}"/>
                <c:set var="pageTitle"
                       value="${text.escape(param.context)} | ${TranslationLocale.get(param.locale).name}" />
            </c:when>
            <c:when test="${text.isNotBlank(param.context)}">
                <c:set var="contextUrlParam" value="&context=${text.escape(param.context)}"/>
                <c:set var="contextBreadCrumb" value="${true}"/>
                <c:set var="pageTitle"
                       value="${text.escape(param.context)}" />
            </c:when>
            <c:when test="${text.isNotBlank(param.locale)}">
                <c:set var="localeUrlParam" value="&locale=${text.escape(param.locale)}"/>
                <c:set var="localeBreadCrumb" value="${true}"/>
                <c:set var="pageTitle"
                       value="${TranslationLocale.get(param.locale).name}" />
            </c:when>
        </c:choose>
        
        
    
        <bundle:layout page="${bundle.path}/layouts/layout.jsp">
            <!-- Sets title and imports js and css specific to this console. -->
            <bundle:variable name="head">
                <c:import url="${bundle.path}/partials/translations/head.jsp" charEncoding="UTF-8"/>
            </bundle:variable>
            
            <!-- BREADCRUMBS START HERE. Remove if not needed. ------------------------------------------->
            <bundle:variable name="breadcrumb">
                <li><a href="${i18nBaseUrl}">Translations</a></li>
                <li><a href="${i18nKappUrl}&page=translations/kapp">${text.escape(i18nKapp.name)}</a></li>
                <c:if test="${contextAndLocaleBreadCrumb}">
                    <li>
                        <a href="${i18nKappUrl}&page=translations/context${contextUrlParam}${localeUrlParam}">${text.escape(param.context)}</a>
                        <span>|</span>
                        <a href="${i18nKappUrl}&page=translations/context${localeUrlParam}">${text.escape(param.locale)}</a>
                    </li>
                </c:if>
                <c:if test="${contextBreadCrumb}">
                    <li><a href="${i18nKappUrl}&page=translations/context${contextUrlParam}">${text.escape(param.context)}</a></li>
                </c:if>
                <c:if test="${keyBreadCrumb}">
                    <li><a href="${i18nKappUrl}&page=translations/key${contextUrlParam}${keyUrlParam}">${text.truncate(text.escape(param.key), 30, '...')}</a></li>
                </c:if>
                <c:if test="${localeBreadCrumb}">
                    <li><a href="${i18nKappUrl}&page=translations/locale${localeUrlParam}">${text.escape(param.locale)}</a></li>
                </c:if>
                <li class="active">Add</li>                
            </bundle:variable>
            <!-- BREADCRUMBS END HERE. ------------------------------------------------------------------->

            <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
            
            <c:choose>
                <c:when test="${pendingChanges.size() > 0}">
                    <a href="${i18nKappUrl}&page=translations/publish" class="pending-publish btn btn-info">
                        <span class="fa fa-lg fa-cloud-upload"></span>
                        <span>There are ${pendingChanges.size()}<span class="plus-placeholder"></span> translations waiting to be published in the ${text.escape(i18nKapp.name)} Kapp.</span>
                    </a>
                </c:when>
                <c:otherwise>
                    <a href="${i18nKappUrl}&page=translations/publish" class="pending-publish btn btn-info hide">
                        <span class="fa fa-lg fa-cloud-upload"></span>
                        <span>Your newly added translations are waiting to be published in the ${text.escape(i18nKapp.name)} Kapp.</span>
                    </a>
                </c:otherwise>
            </c:choose>
            
            <div class="page-header">
                <div class="row">
                    <div class="col-xs-12">
                        <h3>
                            <span>Add</span>
                            <span>${pageTitle}</span>
                            <small>Translations</small>
                        </h3>
                    </div>
                            
                    <div class="col-xs-12">
                        <c:if test="${(contextBreadCrumb || contextAndLocaleBreadCrumb)
                                      && translationSnapshot.getUnexpectedContextNames(i18nKapp).contains(param.context)}">
                            <a class="btn btn-xs btn-warning" 
                               href="${i18nKappUrl}&page=translations/unexpectedContext">
                                Unexpected Context
                            </a>
                        </c:if>
                        <c:if test="${(localeBreadCrumb || contextAndLocaleBreadCrumb)
                                      && translationSnapshot.getUnexpectedLocaleCodes().contains(param.locale)}">
                            <a class="btn btn-xs btn-warning" 
                                href="${i18nKappUrl}&page=translations/unexpectedLocale">
                                Unexpected Locale
                            </a>
                        </c:if>
                    </div>
                </div>
            </div>          
            
            <div class="entries-container">
                <div class="row add-entry-container bs-callout bs-callout-info">
                    <div class="col-xs-12">
                        <table class="table"> 
                            <thead>
                                <tr>
                                    <th style="width:50%">Locale</th>
                                    <th style="width:50%">Context</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>
                                        <select class="form-control input-sm" 
                                                ${translationSnapshot.getEnabledLocaleCodes(param.context).contains(param.locale) ? 'disabled' : ''}
                                                data-entry-locale>
                                            <option value=""></option>
                                            <c:forEach var="localeCode" items="${translationSnapshot.getEnabledLocaleCodes(param.context)}">
                                                <option value="${localeCode}" ${param.locale == localeCode ? 'selected' : ''}>${TranslationLocale.get(localeCode).name} | ${localeCode}</option>
                                            </c:forEach>
                                        </select>
                                    </td>
                                    <td>
                                        <select class="form-control input-sm" 
                                                ${translationSnapshot.getExpectedContextNames(i18nKapp).contains(param.context) ? 'disabled' : ''}
                                                data-entry-context>
                                            <option value=""></option>
                                            <c:forEach var="contextName" items="${translationSnapshot.getExpectedContextNames(i18nKapp)}">
                                                <option value="${contextName}" ${param.context == contextName ? 'selected' : ''}>${contextName}</option>
                                            </c:forEach>
                                        </select>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <div class="col-xs-12">
                        <table class="table"> 
                            <thead>
                                <tr>
                                    <th>Key</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>
                                        <input class="form-control input-sm" 
                                               placeholder="New Key" 
                                               data-entry-key
                                               maxlength="256"
                                               value="${text.isNotBlank(param.key) ? text.escape(param.key) : ''}"
                                               ${text.isNotBlank(param.key) ? 'disabled' : ''}>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <div class="col-xs-12">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>
                                        <span>Translation</span>
                                    </th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>
                                        <textarea class="form-control input-sm" 
                                                  placeholder="New Translation" 
                                                  data-entry-value></textarea>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <div class="col-xs-12">
                        <div class="text-right">
                            <button class="btn btn-success" data-entry-save>
                                <span class="fa fa-check"></span>
                                <span>Save Translation Entry</span>
                            </button>
                        </div>
                    </div>
                </div>
                <br />
                <div class="row new-entries-container">
                    <div class="col-xs-12">
                        <table class="table table-hover table-striped" 
                               data-table-name="Translation Entries"
                               data-add-entries-table data-context="${param.context}"
                               data-empty-message="You have not added any new entries yet.">
                            <thead></thead>
                            <tbody>
                                <tr>
                                    <td class="text-center">
                                        <span class="fa fa-spinner fa-spin"></span>
                                        <span>Loading</span>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <c:import url="${bundle.path}/partials/translations/translationEditor.jsp" charEncoding="UTF-8"/>
            
            <br />  
        
            <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
            
        </bundle:layout>
        
    </c:otherwise>
</c:choose>