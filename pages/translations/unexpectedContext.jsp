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

        <bundle:layout page="${bundle.path}/layouts/layout.jsp">
            <!-- Sets title and imports js and css specific to this console. -->
            <bundle:variable name="head">
                <c:import url="${bundle.path}/partials/translations/head.jsp" charEncoding="UTF-8"/>
            </bundle:variable>
            
            <!-- BREADCRUMBS START HERE. Remove if not needed. ------------------------------------------->
            <bundle:variable name="breadcrumb">
                <li><a href="${i18nBaseUrl}">Translations</a></li>
                <li><a href="${i18nKappUrl}&page=translations/kapp">${text.escape(i18nKapp.name)}</a></li>
                <li class="active">Unexpected Contexts</li>
            </bundle:variable>
            <!-- BREADCRUMBS END HERE. ------------------------------------------------------------------->

            <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
            
            <div class="page-header">
                <div class="row">
                    <div class="col-xs-12">
                        <h2>
                            <span>Unexpected Contexts</span>
                            <small>${text.escape(i18nKapp.name)}</small>
                        </h2>
                    </div>
                </div>
            </div>
                                    
            <div class="row">
                <div class="col-xs-12 overflow-auto">
                    <table class="table table-hover table-striped" data-table-dom
                           data-empty-message="No unexpected contexts."> 
                        <thead>
                            <tr>
                                <th>Context Name</th>
                                <th data-orderable="false"></th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="unexpectedContextName" items="${translationSnapshot.getUnexpectedContextNames(i18nKapp)}"> 
                                <tr>
                                    <td>
                                        <a href="${i18nKappUrl}&page=translations/context&context=${text.escape(unexpectedContextName)}">
                                            ${text.escape(unexpectedContextName)}
                                        </a>
                                    </td>
                                    <td class="text-right">
                                        <button class="btn btn-xs btn-default rename-context-button"
                                                data-context-name="${text.escape(unexpectedContextName)}">
                                            <span class="fa fa-pencil-square-o fa-fw"></span>
                                            <span>Rename Context</span>
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
    
            <!-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -------------------------------->
            <bundle:variable name="aside">
                <h3>${form.name}</h3>
                <h5>${i18nKapp.name}</h5>
                <hr class="border-color-white" />
                <p>
                    An <b>Unexpected Context</b> occurs when there are translation entries with contexts the system is not expecting. 
                    This can occur if a form slug is changed, a form with translations is deleted, or invalid data is imported.
                </p>
                <p>
                    To rename an unexpected context, click the <b class="nowrap"><span class="fa fa-pencil-square-o"></span> Rename Context</b> button 
                    and complete the dialog. All translations in the unexpected context will be moved to the new context and merged with any 
                    existing translations in that context.
                </p>
            </bundle:variable>
            <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
            
        </bundle:layout>
        
    </c:otherwise>
</c:choose>