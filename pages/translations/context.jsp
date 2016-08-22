<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<c:set var="currentKapp" value="${space.getKapp(text.escape(param.kapp))}" scope="request" />
<c:set var="i18nKapp" value="${space.getKapp(text.escape(param.slug))}" scope="request" />
<c:set var="i18nBaseUrl" value="${bundle.kappLocation}/${form.slug}?kapp=${text.escape(param.kapp)}" scope="request" />
<c:set var="i18nKappUrl" value="${i18nBaseUrl}&slug=${text.escape(param.slug)}" scope="request" />
<c:set var="i18nApiUrl" value="${bundle.spaceLocation}/app/apis/translations/v1/kapps/${i18nKapp.slug}" scope="request" />

<!-- Show page content only if Kapp exists. Otherwise redirect to valid page. -->
<c:choose>
    <c:when test="${empty currentKapp}">
        <script>window.location.replace("${bundle.kappLocation}");</script>
    </c:when>
    <c:when test="${empty i18nKapp}">
        <script>window.location.replace("${i18nBaseUrl}");</script>
    </c:when>
    <c:when test="${text.isBlank(param.context)}">
        <script>window.location.replace("${i18nKappUrl}&page=translations/kapp");</script>
    </c:when>
    <c:otherwise>

        <!-- Get Translation Snapshot for the current Kapp -->
        <c:set scope="request" var="translationSnapshot"
               value="${translationManager.getSnapshot(i18nKapp)}" />
        <!-- Get Translation Context Pack for the current context -->
        <c:set scope="request" var="translationContextPack"
               value="${translationSnapshot.getContextPack(i18nKapp, param.context)}" />
        <!-- Get Missing Translations for the current context and locale -->
        <c:choose>
            <c:when test="${text.isNotBlank(param.locale)}">
                <c:set var="missingTranslations" 
                       value="${translationContextPack.getMissingEntriesByLocale(param.locale)}"/>
                <c:set var="localeUrlParam" value="&locale=${text.escape(param.locale)}"/>
                <c:set var="localeUrlApiParam" value="?locale=${text.escape(param.locale)}"/>
                <c:set var="emptyMessageLocale" value="<b>${TranslationLocale.get(param.locale).name}</b> "/>
                <c:if test="${!text.equals(translationSnapshot.defaultLocaleCode, param.locale)}">
                    <c:set var="seedEmpty" value="data-seed=\"true\""/>
                </c:if>
            </c:when>
            <c:otherwise>
                <c:set var="missingTranslations" value="${translationContextPack.getMissingEntries()}"/>
            </c:otherwise>
        </c:choose>
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

            <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
            
            <c:if test="${pendingChanges.size() > 0}">
                <a href="${i18nKappUrl}&page=translations/publish" class="pending-publish btn btn-info">
                    <span class="fa fa-lg fa-cloud-upload"></span>
                    <span>There are ${pendingChanges.size()} translations waiting to be published in the ${text.escape(i18nKapp.name)} Kapp.</span>
                </a>
            </c:if>
            
            <ol class="breadcrumb">
                <li><a href="${i18nBaseUrl}">Translations</a></li>
                <li><a href="${i18nKappUrl}&page=translations/kapp">${text.escape(i18nKapp.name)}</a></li>
                <li class="active">${text.escape(param.context)}</li>
            </ol>
            
            <div class="page-header">
                <div class="row">
                    <div class="col-xs-12">
                        <h3>
                            <span>${text.escape(param.context)}</span>
                            <c:if test="${!translationSnapshot.getExpectedContextNames(i18nKapp).contains(param.context) || text.startsWith(param.context, 'custom.')}">
                                <small class="text-primary">
                                    <span class="fa fa-pencil-square-o fa-fw rename-context-button" 
                                          data-tooltip title="Rename Context" 
                                          data-context-name="${text.escape(param.context)}">
                                    </span>
                                </small>
                            </c:if>
                            <small>Translations</small>
                            <div class="pull-right">
                                <c:choose>
                                    <c:when test="${text.startsWith(param.context, 'form.')}">
                                        <c:set var="exportUrl" 
                                               value="${i18nApiUrl}/forms/${text.substring(text.escape(param.context), 5)}/translations.csv${localeUrlApiParam}"/>
                                    </c:when>
                                    <c:otherwise>
                                        <c:set var="exportUrl" 
                                               value="${i18nApiUrl}/translationContexts/${text.escape(param.context)}/translations.csv${localeUrlApiParam}"/>
                                    </c:otherwise>
                                </c:choose>
                                <a class="btn btn-sm btn-primary" href="${exportUrl}">
                                    <span class="fa fa-download fa-fw"></span> Export
                                </a>
                                <a class="btn btn-sm btn-default" 
                                   href="${i18nKappUrl}&page=translations/add&context=${text.escape(param.context)}${localeUrlParam}">
                                    <span class="fa fa-plus fa-fw"></span> Add Entries
                                </a>
                            </div>
                        </h3>
                    </div>
                            
                    <div class="col-xs-12">
                        <c:if test="${missingTranslations.size() > 0}">
                            <a class="btn btn-xs btn-warning" 
                               href="${i18nKappUrl}&page=translations/missing&context=${text.escape(param.context)}${localeUrlParam}">
                                <span class="fa fa-fw fa-exclamation-triangle"></span> 
                                Missing ${missingTranslations.size()} Translations
                            </a>
                        </c:if>
                        <select class="change-locale pull-right">
                            <option value="${i18nKappUrl}&page=translations/context&context=${text.escape(param.context)}">All Locales</option>
                            <c:forEach var="localeCode" items="${translationSnapshot.getEnabledLocaleCodes(param.context)}">
                                <option value="${i18nKappUrl}&page=translations/context&context=${text.escape(param.context)}&locale=${localeCode}" 
                                    ${param.locale == localeCode ? 'selected' : ''}>
                                    ${TranslationLocale.get(localeCode).name} | ${localeCode}
                                </option>
                            </c:forEach>
                        </select>
                        <c:if test="${translationSnapshot.getUnexpectedContextNames(i18nKapp).contains(param.context)}">
                            <a class="btn btn-xs btn-warning" 
                                href="${i18nKappUrl}&page=translations/unexpectedContext">
                                Unexpected Context
                            </a>
                        </c:if>
                        <c:if test="${text.isNotBlank(param.locale) 
                                      && translationSnapshot.getUnexpectedLocaleCodes().contains(param.locale)}">
                            <a class="btn btn-xs btn-warning" 
                                href="${i18nKappUrl}&page=translations/unexpectedLocale">
                                Unexpected Locale
                            </a>
                        </c:if>
                    </div>
                </div>
            </div>
            
            <div class="row entries-container">
                <div class="col-xs-12">
                    <table class="table table-hover table-striped" 
                           data-state-save="true"
                           id="context_${i18nKapp.slug}_${text.escape(param.context)}_${text.escape(param.locale)}"
                           data-table-source="${i18nKappUrl}&partial=translations/entries.json&context=${text.escape(param.context)}${localeUrlParam}"
                           data-empty-message="No ${emptyMessageLocale}translations found in the <b>${text.escape(param.context)}</b> context."
                           ${seedEmpty} data-delete-all="true"
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
            
        </bundle:layout>
        
    </c:otherwise>
</c:choose>