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
    <c:otherwise>

        <!-- Get Translation Snapshot for the current Kapp -->
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
                <li class="active">Unexpected Locales</li>
            </ol>
            
            <div class="page-header">
                <div class="row">
                    <div class="col-xs-12">
                        <h3>
                            <span>Unexpected Locales</span>
                            <small>${text.escape(i18nKapp.name)}</small>
                        </h3>
                    </div>
                </div>
            </div>
                                    
            <div class="row">
                <div class="col-xs-12">
                    <div class="bs-callout bs-callout-info">
                        An <b>Unexpected Locale</b> occurs when there are 
                        translation entries with locales that are not enabled 
                        for the Kapp. This can occur if a locale is disabled or  
                        invalid data is imported.                        
                    </div>
                </div>
                <div class="col-xs-12">
                    <table class="table table-hover table-striped" data-table-dom
                           data-empty-message="No unexpected contexts."> 
                        <thead>
                            <tr>
                                <th>Language Name</th>
                                <th>Locale Code</th>
                                <th data-orderable="false"></th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="unexpectedLocaleCode" items="${translationSnapshot.getUnexpectedLocaleCodes()}"> 
                                <tr>
                                    <td>${TranslationLocale.get(unexpectedLocaleCode).name}</td>
                                    <td>
                                        <a class="btn btn-xs btn-warning"
                                           href="${i18nKappUrl}&page=translations/locale&locale=${text.escape(unexpectedLocaleCode)}">
                                            ${text.escape(unexpectedLocaleCode)}
                                        </a>
                                    </td>
                                    <td class="text-right">
                                        <button class="btn btn-xs btn-default enable-unexpected-locale-btn"
                                                data-locale-code="${text.escape(unexpectedLocaleCode)}">
                                            <span class="fa fa-plus fa-fw"></span>
                                            <span>Enable Locale</span>
                                        </button>
                                    </td>
                                </tr>
                            </c:forEach> 
                        </tbody>
                    </table>
                </div>
            </div>
            
            <br />
        
            <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
            
        </bundle:layout>
        
    </c:otherwise>
</c:choose>