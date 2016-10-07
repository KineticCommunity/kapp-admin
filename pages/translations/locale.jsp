<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<c:set var="i18nKapp" value="${space.getKapp(text.escape(param.slug))}" scope="request" />
<c:set var="i18nBaseUrl" value="${bundle.kappLocation}/${form.slug}" scope="request" />
<c:set var="i18nKappUrl" value="${i18nBaseUrl}?slug=${text.escape(param.slug)}" scope="request" />
<c:set var="i18nApiUrl" value="${bundle.spaceLocation}/app/apis/translations/v1/kapps/${i18nKapp.slug}" scope="request" />

<!-- Show page content only if selected Kapp exists and locale is specified. -->
<c:choose>
    <c:when test="${empty i18nKapp}">
        <script>window.location.replace("${i18nBaseUrl}");</script>
    </c:when>
    <c:when test="${text.isBlank(param.locale)}">
        <script>window.location.replace("${i18nKappUrl}&page=translations/kapp");</script>
    </c:when>
    <c:otherwise>

        <!-- Get Translation Snapshot for the current Kapp -->
        <c:set scope="request" var="translationSnapshot"
               value="${translationManager.getSnapshot(i18nKapp)}" />
        <!-- Get Missing Translations for the current locale -->
        <c:set var="missingTranslations" 
               value="${translationSnapshot.getMissingEntriesByLocale(i18nKapp, param.locale)}"/>
        <!-- Get Cached translations and calculate changes waiting to be published -->
        <c:set scope="request" var="publishedSnapshot"
               value="${translationManager.getCachedSnapshot(i18nKapp)}" />
        <c:set var="pendingChanges" 
               value="${translationManager.getChanges(i18nKapp, publishedSnapshot, translationSnapshot)}"/>
        
        <bundle:layout page="${bundle.path}/layouts/layout.jsp">
            <!-- Sets title and imports js and css specific to this console. -->
            <bundle:variable name="head">
                <c:import url="${bundle.path}/partials/translations/head.jsp" charEncoding="UTF-8"/>
            </bundle:variable>
            
            <!-- BREADCRUMBS START HERE. Remove if not needed. ------------------------------------------->
            <bundle:variable name="breadcrumb">
                <li><a href="${i18nBaseUrl}">Translations</a></li>
                <li><a href="${i18nKappUrl}&page=translations/kapp">${text.escape(i18nKapp.name)}</a></li>
                <li class="active">${text.escape(param.locale)}</li>
            </bundle:variable>
            <!-- BREADCRUMBS END HERE. ------------------------------------------------------------------->

            <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
            
            <c:if test="${pendingChanges.size() > 0}">
                <a href="${i18nKappUrl}&page=translations/publish" class="pending-publish btn btn-info">
                    <span class="fa fa-lg fa-cloud-upload"></span>
                    <span>There are ${pendingChanges.size()} translations waiting to be published in the ${text.escape(i18nKapp.name)} Kapp.</span>
                </a>
            </c:if>
            
            <div class="page-header">
                <div class="row">
                    <div class="col-xs-12">
                        <h3>
                            <span>${TranslationLocale.get(param.locale).name}</span>
                            <small>Translations</small>
                            <div class="pull-right">
                                <a class="btn btn-sm btn-primary" 
                                   href="${i18nApiUrl}/translations.csv?locale=${text.escape(param.locale)}">
                                    <span class="fa fa-download fa-fw"></span> Export
                                </a>
                                <a class="btn btn-sm btn-default" 
                                   href="${i18nKappUrl}&page=translations/add&locale=${text.escape(param.locale)}">
                                    <span class="fa fa-plus fa-fw"></span> Add Entries
                                </a>
                            </div>
                        </h3>
                    </div>
                            
                    <div class="col-xs-12">
                        <c:if test="${missingTranslations.size() > 0}">
                            <a class="btn btn-xs btn-warning m-t-1" 
                               href="${i18nKappUrl}&page=translations/missing&locale=${text.escape(param.locale)}">
                                <span class="fa fa-fw fa-exclamation-triangle"></span>
                                Missing ${missingTranslations.size()} Translations
                            </a>
                        </c:if>
                        <c:if test="${translationSnapshot.getUnexpectedLocaleCodes().contains(param.locale)}">
                            <a class="btn btn-xs btn-warning m-t-1" 
                                href="${i18nKappUrl}&page=translations/unexpectedLocale">
                                Unexpected Locale
                            </a>
                        </c:if>
                        <select class="change-locale pull-right m-t-1">
                            <c:if test="${!translationSnapshot.enabledLocaleCodes.contains(param.locale)}">
                                <option value="${i18nKappUrl}&page=translations/locale&locale=${text.escape(param.locale)}" selected>
                                    Unexpected Locale: ${text.escape(param.locale)}
                                </option>
                            </c:if>
                            <c:forEach var="localeCode" items="${translationSnapshot.enabledLocaleCodes}">
                                <option value="${i18nKappUrl}&page=translations/locale&locale=${localeCode}" 
                                    ${param.locale == localeCode ? 'selected' : ''}>
                                    ${TranslationLocale.get(localeCode).name} | ${localeCode}
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
            </div>
            
            <div class="row entries-container">
                <div class="col-xs-12 overflow-auto">
                    <table class="table table-hover table-striped" 
                           data-state-save="true"
                           id="locale_${i18nKapp.slug}_${text.escape(param.locale)}"
                           data-table-source="${i18nKappUrl}&partial=translations/entries.json&locale=${text.escape(param.locale)}"
                           data-empty-message="No <b>${TranslationLocale.get(param.locale).name}</b> translations found."
                           data-delete-all="true"
                           data-context="${text.escape(param.context)}" 
                           data-locale="${text.escape(param.locale)}">
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

            <c:import url="${bundle.path}/partials/translations/translationEditor.jsp" charEncoding="UTF-8"/>
            
            <br />
        
            <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
    
            <!-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -------------------------------->
            <bundle:variable name="aside">
                <h3>${form.name}</h3>
                <h4>${i18nKapp.name}</h4>
                <hr class="border-color-white" />
                <p>The table displays all the translations for the <b class="nowrap">${TranslationLocale.get(param.locale).name} | ${param.locale}</b> locale.</p>
                <p>To export the translations, click the <b class="nowrap"><span class="fa fa-download"></span> Export</b> button.</p>
                <hr class="border-color-white" />
                <p>
                    To add new translation entries for the <b class="nowrap">${TranslationLocale.get(param.locale).name} | ${param.locale}</b> locale, 
                    click the <b class="nowrap"><span class="fa fa-plus"></span> Add Entries</b> button.
                </p>
                <p>To edit a translation, click the edit <span class="fa fa-pencil"></span> button.</p>
                <p>
                    To delete  a translation, click the delete <span class="fa fa-times"></span> button. 
                    If the delete button is disabled, the key is a placeholder and cannot be deleted. 
                </p>
                <div class="m-l-2">
                    <p>
                        Placeholders are keys that are known to exist and are therefore 
                        being displayed to show the user what keys may need to be translated.
                    </p>
                </div>
                <p>
                    To delete <b>all</b> translations for the <b class="nowrap">${TranslationLocale.get(param.locale).name} | ${param.locale}</b> locale, 
                    open the actions menu <span class="fa fa-chevron-down"></span> at the top of the table and select the <b>Delete All</b> option. 
                </p>
                <p>To view all the translations for a key, click on the key value.</p>
                <hr class="border-color-white" />
                <p><b>
                    <span class="fa fa-info-circle"></span> After translations are updated or deleted, 
                    they will need to be published before they are available within the application. 
                    A publish <span class="fa fa-cloud-upload"></span> banner will appear at the top of the page 
                    to notify you when translations are waiting to be published.
                </b></p>
            </bundle:variable>
            <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
            
        </bundle:layout>
        
    </c:otherwise>
</c:choose>