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
    
        <c:set scope="request" var="translationSnapshot"
               value="${translationManager.getSnapshot(i18nKapp)}" />
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
            
            <ol class="breadcrumb">
                <li><a href="${i18nBaseUrl}">Translations</a></li>
                <li><a href="${i18nKappUrl}&page=translations/kapp">${text.escape(i18nKapp.name)}</a></li>
                <li class="active">Publish</li>
            </ol>
            
            <div class="page-header">
                <div class="row">
                    <div class="col-xs-12">
                        <h3>
                            <span>Publish Translations</span>
                            <small>${text.escape(i18nKapp.name)}</small>
                            <div class="pull-right">
                                <button class="btn btn-sm btn-default publish-btn" ${pendingChanges.size() <= 0 ? 'disabled' : ''}>
                                    <span class="fa fa-cloud-upload fa-fw"></span> Publish
                                </button>
                            </div>
                        </h3>
                    </div>
                </div>
            </div>
            
            <div class="row entries-container">
                <div class="col-xs-12">
                    <table class="table table-hover table-striped" 
                           data-table-dom data-table-name="Changes Pending Publish"
                           data-empty-message="No translations waiting to be published."> 
                        <thead>
                            <tr>
                                <th style="width:10%;">Locale</th>
                                <th style="width:15%;">Context</th>
                                <th>Key</th>
                                <th>Current Translation</th>
                                <th>New Translation</th>
                                <th style="width:10%;">Status</th>
                            </tr>
                        </thead>
                        <tbody>
                             <c:forEach var="change" items="${pendingChanges}"> 
                                <tr>
                                    <td>
                                        <span class="btn-xs btn-subtle" disabled data-tooltip title=${TranslationLocale.get(change.getLocaleCode()).name}>
                                            ${text.escape(change.getLocaleCode())}
                                        </span>
                                    </td>
                                    <td>
                                        <span class="btn-xs btn-subtle" data-tooltip title=${change.getContextName()}>
                                            <span class="ellipsis">${text.escape(change.getContextName())}</span>
                                        </span>
                                    </td>
                                    <td class="ellipsis">
                                        <a href="${i18nKappUrl}&page=translations/key&context=${text.escape(change.getContextName())}&key=${text.escape(change.getKey())}">
                                            ${text.escape(change.getKey())}
                                        </a>
                                    </td>
                                    <td class="ellipsis">
                                        ${text.escape(change.getSourceValue())}
                                    </td>
                                    <td class="ellipsis">
                                        ${text.escape(change.getPendingValue())}
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${text.equals('Added', change.getStatus())}">
                                                <c:set var="statusType" value="success" />
                                            </c:when>
                                            <c:when test="${text.equals('Removed', change.getStatus())}">
                                                <c:set var="statusType" value="danger" />
                                            </c:when>
                                            <c:otherwise>
                                                <c:set var="statusType" value="subtle" />
                                            </c:otherwise>
                                        </c:choose>
                                        <span class="btn-xs btn-${statusType} pull-right" disabled>
                                            ${text.escape(change.getStatus())}
                                        </span>
                                    </td>
                                </tr>
                             </c:forEach> 
                        </tbody>
                    </table>
                </div>
            </div>
        
            <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
            
        </bundle:layout>
        
    </c:otherwise>
</c:choose>