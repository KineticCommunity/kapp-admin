<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<%@include file="../../bundle/router.jspf" %>
<c:set var="currentKapp" value="${space.getKapp(text.escape(param.kapp))}" scope="request" />
<c:set var="i18nBaseUrl" value="${bundle.kappLocation}/${form.slug}?kapp=${text.escape(param.kapp)}" scope="request" />

<!-- Show page content only if Kapp exists. Otherwise redirect to valid page. -->
<c:choose>
    <c:when test="${empty currentKapp}">
        <script>window.location.replace("${bundle.kappLocation}");</script>
    </c:when>
    <c:otherwise>
    
        <bundle:layout page="${bundle.path}/layouts/layout.jsp">
            <!-- Sets title and imports js and css specific to this console. -->
            <bundle:variable name="head">
                <c:import url="${bundle.path}/partials/translations/head.jsp" charEncoding="UTF-8"/>
            </bundle:variable>

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
                                    <td><a href="${i18nBaseUrl}&page=translations/kapp&slug=${kapp.slug}">${text.escape(kapp.name)}</a></td>
                                    <td>
                                        <c:set var="defaultLocale" value="${translationManager.getDefaultLocale(kapp)}"/>
                                        <c:choose>
                                            <c:when test="${defaultLocale != null}">
                                                <a class="btn btn-xs btn-info" 
                                                   data-tooltip title="${defaultLocale.name}"
                                                   href="${i18nBaseUrl}&page=translations/locale&slug=${kapp.slug}&locale=${defaultLocale.code}">
                                                    ${defaultLocale.code}
                                                </a>
                                            </c:when>
                                            <c:otherwise>
                                                <a class="btn btn-xs btn-warning" 
                                                   href="{i18nBaseUrl}&page=translations/locales&slug=${kapp.slug}">
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
                                                       href="${i18nKappUrl}&page=translations/locale&locale=${locale.code}">
                                                        ${locale.code}
                                                    </a>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <a class="btn btn-xs btn-warning" 
                                                   href="${i18nBaseUrl}&page=translations/locales&slug=${kapp.slug}">
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
            
        </bundle:layout>
        
    </c:otherwise>
</c:choose>