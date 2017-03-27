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

        <c:set scope="request" var="translationSnapshot"
               value="${translationManager.getSnapshot(i18nKapp)}" />
        <!-- Get Cached translations and calculate changes waiting to be published -->
        <c:set scope="request" var="publishedSnapshot"
               value="${translationManager.getCachedSnapshot(i18nKapp)}" />
        <c:set var="pendingChanges" 
               value="${translationManager.getChanges(i18nKapp, publishedSnapshot, translationSnapshot)}"/>
        
        <c:choose>
            <c:when test="${text.isNotBlank(param.context) && text.isNotBlank(param.key)}">
                <c:set var="missingTranslations"
                       value="${translationSnapshot.getMissingEntriesByContextAndKey(i18nKapp, param.context, param.key)}" />
                <c:set var="missingTranslationsDataUrl"
                       value="${i18nKappUrl}&partial=translations/entries.json&context=${text.escape(param.context)}&key=${text.escape(param.key)}&missing" />
                <c:choose>
                    <c:when test="${text.startsWith(param.context, 'form.')}">
                        <c:set var="exportUrl" 
                               value="${i18nApiUrl}/forms/${text.substring(text.escape(param.context), 5)}/translations.csv?key=${text.escape(param.key)}&missing"/>
                    </c:when>
                    <c:otherwise>
                        <c:set var="exportUrl" 
                               value="${i18nApiUrl}/translationContexts/${text.escape(param.context)}/translations.csv?key=${text.escape(param.key)}&missing"/>
                    </c:otherwise>
                </c:choose>
                <c:set var="contextBreadCrumb" value="${true}"/>
                <c:set var="keyBreadCrumb" value="${true}"/>
                <c:set var="pageTitle"
                       value="${text.truncate(text.escape(param.key), 30, '...')}"/>
            </c:when>
            <c:when test="${text.isNotBlank(param.context) && text.isNotBlank(param.locale)}">
                <c:set var="missingTranslations"
                       value="${translationSnapshot.getMissingEntriesByContextAndLocale(i18nKapp, param.context, param.locale)}" />
                <c:set var="missingTranslationsDataUrl"
                       value="${i18nKappUrl}&partial=translations/entries.json&context=${text.escape(param.context)}&locale=${text.escape(param.locale)}&missing" />
                <c:choose>
                    <c:when test="${text.startsWith(param.context, 'form.')}">
                        <c:set var="exportUrl" 
                               value="${i18nApiUrl}/forms/${text.substring(text.escape(param.context), 5)}/translations.csv?locale=${text.escape(param.locale)}&missing"/>
                    </c:when>
                    <c:otherwise>
                        <c:set var="exportUrl" 
                               value="${i18nApiUrl}/translationContexts/${text.escape(param.context)}/translations.csv?locale=${text.escape(param.locale)}&missing"/>
                    </c:otherwise>
                </c:choose>
                <c:set var="localeUrlParam" value="&locale=${text.escape(param.locale)}"/>
                <c:set var="contextUrlParam" value="&context=${text.escape(param.context)}"/>
                <c:set var="contextBreadCrumb" value="${true}"/>
                <c:set var="pageTitle"
                       value="${text.escape(param.context)}" />
            </c:when>
            <c:when test="${text.isNotBlank(param.context)}">
                <c:set var="missingTranslations"
                       value="${translationSnapshot.getMissingEntriesByContext(i18nKapp, param.context)}" />
                <c:set var="missingTranslationsDataUrl"
                       value="${i18nKappUrl}&partial=translations/entries.json&context=${text.escape(param.context)}&missing" />
                <c:choose>
                    <c:when test="${text.startsWith(param.context, 'form.')}">
                        <c:set var="exportUrl" 
                               value="${i18nApiUrl}/forms/${text.substring(text.escape(param.context), 5)}/translations.csv?missing"/>
                    </c:when>
                    <c:otherwise>
                        <c:set var="exportUrl" 
                               value="${i18nApiUrl}/translationContexts/${text.escape(param.context)}/translations.csv?missing"/>
                    </c:otherwise>
                </c:choose>
                <c:set var="contextUrlParam" value="&context=${text.escape(param.context)}"/>
                <c:set var="contextBreadCrumb" value="${true}"/>
                <c:set var="pageTitle"
                       value="${text.escape(param.context)}" />
            </c:when>
            <c:when test="${text.isNotBlank(param.locale)}">
                <c:set var="missingTranslations"
                       value="${translationSnapshot.getMissingEntriesByLocale(i18nKapp, param.locale)}" />
                <c:set var="missingTranslationsDataUrl"
                       value="${i18nKappUrl}&partial=translations/entries.json&locale=${text.escape(param.locale)}&missing" />
                <c:set var="exportUrl" 
                        value="${i18nApiUrl}/translations.csv?locale=${text.escape(param.locale)}&missing"/>
                <c:set var="localeBreadCrumb" value="${true}"/>
                <c:set var="pageTitle"
                       value="${TranslationLocale.get(param.locale).name}" />
            </c:when>
            <c:otherwise>
                <c:set var="missingTranslations"
                       value="${translationSnapshot.getMissingEntries(i18nKapp)}" />
                <c:set var="missingTranslationsDataUrl"
                       value="${i18nKappUrl}&partial=translations/entries.json&missing" />
                <c:set var="exportUrl" 
                        value="${i18nApiUrl}/translations.csv?missing"/>
                <c:set var="pageTitle"
                       value="All" />
            </c:otherwise>
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
                <c:if test="${contextBreadCrumb}">
                    <li><a href="${i18nKappUrl}&page=translations/context&context=${text.escape(param.context)}${localeUrlParam}">${text.escape(param.context)}</a></li>
                </c:if>
                <c:if test="${keyBreadCrumb}">
                    <li><a href="${i18nKappUrl}&page=translations/key&context=${text.escape(param.context)}&key=${text.escape(param.key)}">${text.truncate(text.escape(param.key), 30, '...')}</a></li>
                </c:if>
                <c:if test="${localeBreadCrumb}">
                    <li><a href="${i18nKappUrl}&page=translations/locale&locale=${text.escape(param.locale)}">${text.escape(param.locale)}</a></li>
                </c:if>
                <li class="active">Missing</li>
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
                        <h2>
                            <span>${pageTitle}</span>
                            <small>Missing Translations</small>
                            <div class="pull-right">
                                <a class="btn btn-default" href="${exportUrl}">
                                    <span class="fa fa-download fa-fw"></span> Export
                                </a>
                            </div>
                        </h2>
                    </div>
                    <c:if test="${empty keyBreadCrumb}">
                        <div class="col-xs-12">
                            <select class="change-locale pull-right m-t-1">
                                <option value="${i18nKappUrl}&page=translations/missing${contextUrlParam}">All Locales</option>
                                <c:forEach var="localeCode" 
                                           items="${empty contextBreadCrumb 
                                                    ? translationSnapshot.enabledLocaleCodes 
                                                    : translationSnapshot.getEnabledLocaleCodes(param.context)}">
                                    <option value="${i18nKappUrl}&page=translations/missing${contextUrlParam}&locale=${localeCode}" 
                                        ${param.locale == localeCode ? 'selected' : ''}>
                                        ${TranslationLocale.get(localeCode).name} | ${localeCode}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                    </c:if>
                </div>
            </div>
            
            <div class="row entries-container">
                <c:if test="${not empty keyBreadCrumb}">
                    <div class="col-xs-12">
                        <table class="table table-hover table-striped" data-sort="false" data-dom="t" data-table-dom> 
                            <thead>
                                <tr>
                                    <th>Key</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>${text.escape(param.key)}</td>
                                </tr>
                            </tbody>
                        </table>
                        <br />
                    </div>
                </c:if>
                <div class="col-xs-12 overflow-auto">
                    <table class="table table-hover table-striped" data-state-save="true"
                           id="missing_${i18nKapp.slug}_${text.escape(param.context)}_${text.escape(param.locale)}"
                           data-table-source="${missingTranslationsDataUrl}"
                           data-empty-message="No missing translations.">
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
                <h5>${i18nKapp.name}</h5>
                <hr class="border-color-white" />
                <c:choose>
                    <c:when test="${text.isNotBlank(param.context) && text.isNotBlank(param.key)}">
                        <p>The table displays all the <b>missing</b> translations for the selected key, which is shown above the table.</p>
                    </c:when>
                    <c:when test="${text.isNotBlank(param.context) && text.isNotBlank(param.locale)}">
                        <p>
                            The table displays all the <b>missing</b> translations for the <b>${param.context}</b> context
                            and <b class="nowrap">${TranslationLocale.get(param.locale).name} | ${param.locale}</b> locale.
                        </p>
                    </c:when>
                    <c:when test="${text.isNotBlank(param.context)}">
                        <p>The table displays all the <b>missing</b> translations for the <b>${param.context}</b> context.</p>
                    </c:when>
                    <c:when test="${text.isNotBlank(param.locale)}">
                        <p>The table displays all the <b>missing</b> translations for the <b class="nowrap">${TranslationLocale.get(param.locale).name} | ${param.locale}</b> locale.</p>
                    </c:when>
                    <c:otherwise>
                        <p>The table displays all the <b>missing</b> translations.</p>
                    </c:otherwise>
                </c:choose>
                <p>
                    Translations are considered missing if the existing keys are not translated in every available language. 
                    Translations in the default language are never considered missing, as they default to the key.
                </p>
                <p>To export the translations, click the <b class="nowrap"><span class="fa fa-download"></span> Export</b> button.</p>
                <p>To edit a translation, click the edit <span class="fa fa-pencil"></span> button.</p>
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