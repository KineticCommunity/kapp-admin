<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<%@include file="../../bundle/router.jspf" %>
<c:set var="i18nBaseUrl" value="${bundle.kappLocation}/${form.slug}" scope="request" />

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <!-- Sets title and imports js and css specific to this console. -->
    <bundle:variable name="head">
        <c:import url="${bundle.path}/partials/translations/head.jsp" charEncoding="UTF-8"/>
    </bundle:variable>
    
    <!-- BREADCRUMBS START HERE. Remove if not needed. ------------------------------------------->
    <bundle:variable name="breadcrumb">
        <li class="active">${form.name}</li>
    </bundle:variable>
    <!-- BREADCRUMBS END HERE. ------------------------------------------------------------------->

    <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
    
    <div class="page-header">
        <h3>${text.escape(form.name)}</h3>
    </div>
    
    <div class="row">
        <div class="col-xs-12">
            <table class="table table-hover table-striped" 
                   data-table-dom data-table-name="Kapps"> 
                <thead>
                    <tr>
                        <th>Kapp</th>
                        <th data-orderable="false">Default Locale</th>
                        <th data-orderable="false" style="width:50%;">Enabled Locales</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="kapp" items="${space.kapps}">
                        <tr>
                            <td><a href="${i18nBaseUrl}?page=translations/kapp&slug=${kapp.slug}">${text.escape(kapp.name)}</a></td>
                            <td>
                                <c:set var="defaultLocale" value="${translationManager.getDefaultLocale(kapp)}"/>
                                <c:choose>
                                    <c:when test="${defaultLocale != null}">
                                        <a class="btn btn-xs btn-info" 
                                           data-tooltip title="${defaultLocale.name}"
                                           href="${i18nBaseUrl}?page=translations/locale&slug=${kapp.slug}&locale=${defaultLocale.code}">
                                            ${defaultLocale.code}
                                        </a>
                                    </c:when>
                                    <c:otherwise>
                                        <a class="btn btn-xs btn-warning" 
                                           href="${i18nBaseUrl}?page=translations/locales&slug=${kapp.slug}">
                                            <span class="fa fa-exclamation-triangle fa-fw"></span> Not Set
                                        </a>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${translationManager.getEnabledLocales(kapp).size() > 0}">
                                        <c:forEach var="locale" items="${translationManager.getEnabledLocales(kapp)}">
                                            <a class="btn btn-xs btn-success" 
                                               data-tooltip title="${locale.name}"
                                               href="${i18nBaseUrl}?page=translations/locale&slug=${kapp.slug}&locale=${locale.code}">
                                                ${locale.code}
                                            </a>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <a class="btn btn-xs btn-warning" 
                                           href="${i18nBaseUrl}?page=translations/locales&slug=${kapp.slug}">
                                            <span class="fa fa-exclamation-triangle fa-fw"></span> No Enabled Locales
                                        </a>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>

    <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
    
    <!-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -------------------------------->
    <bundle:variable name="aside">
        <h3>${form.name}</h3>
        <p>${form.description}</p>
        <hr class="border-color-white" />
        <p>To manage a Kapp's translations, click the name of the Kapp.</p>
        <p>Space level translations should be added to the <i>${kapp.name}</i> Kapp.</p>
        <hr class="border-color-white" />
        <p>The <b>Default Locale</b> is the locale which will be used if a translation is not found in the user's preferred language.</p>
        <p>An <b>Enabled Locale</b> is a locale that is used by the application and may have translations. Locales are enabled by an administrator.</p>
    </bundle:variable>
    <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
    
</bundle:layout>