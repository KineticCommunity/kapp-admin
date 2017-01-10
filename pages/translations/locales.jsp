<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<c:set var="currentKapp" value="${space.getKapp(text.escape(param.kapp))}" scope="request" />
<c:set var="i18nKapp" value="${space.getKapp(text.escape(param.slug))}" scope="request" />
<c:set var="i18nBaseUrl" value="${bundle.kappLocation}/${form.slug}?kapp=${text.escape(param.kapp)}" scope="request" />
<c:set var="i18nKappUrl" value="${i18nBaseUrl}&slug=${text.escape(param.slug)}" scope="request" />

<!-- Show page content only if Kapp exists. Otherwise redirect to valid page. -->
<c:choose>
    <c:when test="${empty currentKapp}">
        <script>window.location.replace("${bundle.kappLocation}");</script>
    </c:when>
    <c:when test="${empty i18nKapp}">
        <script>window.location.replace("${i18nBaseUrl}");</script>
    </c:when>
    <c:otherwise>
        
        <c:set scope="request" var="translationSnapshot"
               value="${translationManager.getSnapshot(i18nKapp)}" />

        <bundle:layout page="${bundle.path}/layouts/layout.jsp">
            <!-- Sets title and imports js and css specific to this console. -->
            <bundle:variable name="head">
                <c:import url="${bundle.path}/partials/translations/head.jsp" charEncoding="UTF-8"/>
            </bundle:variable>

            <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
            
            <ol class="breadcrumb">
                <li><a href="${i18nBaseUrl}">Translations</a></li>
                <li><a href="${i18nKappUrl}&page=translations/kapp">${text.escape(i18nKapp.name)}</a></li>
                <li class="active">Locales</li>
            </ol>
                
            <div class="page-header">
                <h3>
                    Manage Locales
                    <small>${text.escape(i18nKapp.name)}</small>
                </h3>
                
                <c:set var="allMissingTranslations" 
                       value="${translationSnapshot.getMissingEntries(i18nKapp)}"/>
                <c:if test="${allMissingTranslations.size() > 0}">
                    <a class="btn btn-xs btn-warning" 
                       href="${i18nKappUrl}&page=translations/missing">
                        <span class="fa fa-fw fa-exclamation-triangle"></span>
                        Missing ${allMissingTranslations.size()} Translations
                     </a>
                </c:if>
            </div>
                
            <c:set var="defaultLocaleCode" value="${translationSnapshot.defaultLocaleCode}"/>
            
            <div class="row">
                <div class="col-xs-12">
                    <table class="table table-hover table-striped" 
                           data-table-dom data-table-name="Enabled Locales"
                           data-empty-message="No enabled locales found. Please enable locales using the dropdown below.">
                        <thead>
                            <tr>
                                <th style="width:50%;">Name</th>
                                <th style="width:45%;">Code</th>
                                <th data-orderable="false" style="width:5%;"></th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="localeCode" items="${translationSnapshot.enabledLocaleCodes}">
                                <c:set var="missingTranslations" value="${translationSnapshot.getMissingEntriesByLocale(i18nKapp, localeCode)}"/>
                                <tr data-locale="${localeCode}" data-locale-name="${TranslationLocale.get(localeCode).name}">
                                    <td>
                                        <c:choose>
                                            <c:when test="${defaultLocaleCode eq localeCode}">
                                                <b>${TranslationLocale.get(localeCode).name}</b>
                                                <span class="btn-xs btn-info" disabled>Default Locale</span>
                                            </c:when>
                                            <c:otherwise>
                                                ${TranslationLocale.get(localeCode).name}
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <a class="btn btn-xs ${defaultLocaleCode eq localeCode ? 'btn-info' : 'btn-success'}" 
                                           href="${i18nKappUrl}&page=translations/locale&locale=${localeCode}">
                                            ${localeCode}
                                        </a>
                                        <c:if test="${missingTranslations.size() > 0}">
                                            <a class="btn btn-xs btn-warning pull-right" 
                                               href="${i18nKappUrl}&page=translations/missing&locale=${localeCode}">
                                                <span class="fa fa-fw fa-exclamation-triangle"></span>
                                                Missing ${missingTranslations.size()}
                                            </a>
                                        </c:if>
                                    </td>
                                    <td>
                                        <c:if test="${defaultLocaleCode ne localeCode}">
                                            <div class="dropdown more-actions pull-right">
                                                <span data-toggle="dropdown" class="fa fa-chevron-down"></span>
                                                <ul role="menu" class="dropdown-menu dropdown-menu-right">
                                                    <li><a class="disable-locale-btn">Disable Locale</a></li>
                                                    <li><a class="default-locale-btn">Make Default</a></li>
                                                </ul>
                                            </div>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
                <div class="col-xs-12">
                    <table class="table">
                        <tbody>
                            <tr>
                                <td style="width:50%;">
                                    <select class="form-control input-sm enable-locale">
                                        <c:forEach var="localeCode" items="${AdminHelper.sortLocaleCodesByName(translationSnapshot.disabledLocaleCodes)}">
                                            <option value="${localeCode}">${TranslationLocale.get(localeCode).name}</option>
                                        </c:forEach>
                                    </select>
                                </td>
                                <td style="width:35%;" class="locale-code-cell"></td>
                                <td style="width:15%;" class="text-right">
                                    <button class="btn btn-sm btn-success enable-locale-btn" type="button" disabled>
                                        <span class="fa fa-plus"></span>
                                        Enable Locale
                                    </button>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        
            <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
            
        </bundle:layout>
        
    </c:otherwise>
</c:choose>