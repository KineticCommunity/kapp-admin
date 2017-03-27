<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<c:set var="i18nKapp" value="${space.getKapp(text.escape(param.slug))}" scope="request" />
<c:set var="i18nBaseUrl" value="${bundle.kappLocation}/${form.slug}" scope="request" />
<c:set var="i18nKappUrl" value="${i18nBaseUrl}?slug=${text.escape(param.slug)}" scope="request" />
<c:set var="i18nApiUrl" value="${bundle.spaceLocation}/app/apis/translations/v1/kapps/${i18nKapp.slug}" scope="request" />

<!-- Show page content only if selected Kapp exists and context and key are specified. -->
<c:choose>
    <c:when test="${empty i18nKapp}">
        <script>window.location.replace("${i18nBaseUrl}");</script>
    </c:when>
    <c:when test="${text.isBlank(param.context)}">
        <script>window.location.replace("${i18nKappUrl}&page=translations/kapp");</script>
    </c:when>
    <c:when test="${text.isBlank(param.key)}">
        <script>window.location.replace("${i18nKappUrl}&page=translations/context&context=${text.escape(param.context)}");</script>
    </c:when>
    <c:otherwise>
        
        <!-- Get Translation Snapshot for the current Kapp -->
        <c:set scope="request" var="translationSnapshot"
               value="${translationManager.getSnapshot(i18nKapp)}" />
        <!-- Get Translation Context Pack for the current context -->
        <c:set scope="request" var="translationContextPack"
               value="${translationSnapshot.getContextPack(i18nKapp, param.context)}" />
        <!-- Get Missing Translations for the current context and key -->
        <c:set var="missingTranslations" 
               value="${translationContextPack.getMissingEntriesByKey(param.key)}"/>
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
                <li><a href="${i18nKappUrl}&page=translations/context&context=${text.escape(param.context)}">${text.escape(param.context)}</a></li>
                <li class="active">${text.truncate(text.escape(param.key), 30, '...')}</li>
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
                            <span>${text.truncate(text.escape(param.key), 30, '...')}</span>
                            <small>Translations</small>
                            <div class="pull-right">
                                <c:choose>
                                    <c:when test="${text.startsWith(param.context, 'form.')}">
                                        <c:set var="exportUrl" 
                                               value="${i18nApiUrl}/forms/${text.substring(text.escape(param.context), 5)}/translations.csv?key=${text.escape(param.key)}"/>
                                    </c:when>
                                    <c:otherwise>
                                        <c:set var="exportUrl" 
                                               value="${i18nApiUrl}/translationContexts/${text.escape(param.context)}/translations.csv?key=${text.escape(param.key)}"/>
                                    </c:otherwise>
                                </c:choose>
                                <a class="btn btn-default" href="${exportUrl}">
                                    <span class="fa fa-download fa-fw"></span> Export
                                </a>
                                <a class="btn btn-tertiary" 
                                   href="${i18nKappUrl}&page=translations/add&context=${text.escape(param.context)}&key=${text.escape(param.key)}">
                                    <span class="fa fa-plus fa-fw"></span> Add Entries
                                </a>
                            </div>
                        </h2>
                    </div>
                            
                    <div class="col-xs-12">
                        <c:if test="${missingTranslations.size() > 0}">
                            <a class="btn btn-xs btn-warning m-t-1" 
                               href="${i18nKappUrl}&page=translations/missing&context=${text.escape(param.context)}&key=${text.escape(param.key)}">
                                <span class="fa fa-fw fa-exclamation-triangle"></span>
                                Missing ${missingTranslations.size()} Translations
                            </a>
                        </c:if>
                        <c:if test="${translationSnapshot.getUnexpectedContextNames(i18nKapp).contains(param.context)}">
                            <a class="btn btn-xs btn-warning m-t-1" 
                               href="${i18nKappUrl}&page=translations/unexpectedContext">
                                Unexpected Context
                            </a>
                        </c:if>
                    </div>
                </div>
            </div>          
            
            <div class="row entries-container">
                <div class="col-xs-12 overflow-auto">
                    <table class="table table-hover table-striped" data-sort="false" data-dom="t" data-table-dom> 
                        <thead>
                            <tr>
                                <th>Key</th>
                                <th data-orderable="false" style="width:8%;min-width:75px;"></th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>${text.escape(param.key)}</td>
                                <td>
                                    <div class="btn-group pull-right" role="group">
                                         <button class="edit-translation-key-btn btn btn-xs btn-default" 
                                                 type="button"
                                                 data-key="${text.escape(param.key)}"
                                                 data-context="${text.escape(param.context)}">
                                             <span class="fa fa-pencil"></span>
                                         </button>
                                        <button class="delete-translation-key-btn btn btn-xs btn-danger" 
                                                type="button"
                                                data-key="${text.escape(param.key)}"
                                                data-context="${text.escape(param.context)}">
                                            <span class="fa fa-times"></span>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                    <br />
                </div>
                <div class="col-xs-12 overflow-auto">
                    <table class="table table-hover table-striped" data-state-save="true" 
                           id="key_${i18nKapp.slug}_${text.escape(param.context)}"
                           data-table-source="${i18nKappUrl}&partial=translations/entries.json&context=${text.escape(param.context)}&key=${text.escape(param.key)}"
                           data-empty-message="No translations found for the above key in the <b>${text.escape(param.context)}</b> context.">
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
                <p>The table displays all the translations for the selected key, which is shown above the table.</p>
                <p>To export the translations, click the <b class="nowrap"><span class="fa fa-download"></span> Export</b> button.</p>
                <hr class="border-color-white" />
                <p>
                    To add new translation entries for the selected key, click the 
                    <b class="nowrap"><span class="fa fa-plus"></span> Add Entries</b> button.
                </p>
                <p>To edit the <u>key</u>, click the edit <span class="fa fa-pencil"></span> button next to the key.</p>
                <p>To delete the <u>key</u> and all of its translations, click the delete <span class="fa fa-times"></span> button next to the key.</p>
                <p>To edit a translation, click the edit <span class="fa fa-pencil"></span> button next to the translation.</p>
                <p>
                    To delete a translation, click the delete <span class="fa fa-times"></span> button next to the translation. 
                    If the delete button is disabled, the key is a placeholder and cannot be deleted. 
                </p>
                <div class="m-l-2">
                    <p>
                        Placeholders are keys that are known to exist and are therefore 
                        being displayed to show the user what keys may need to be translated.
                    </p>
                </div>
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