<%@page pageEncoding="UTF-8" contentType="application/json" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<c:set var="i18nKappUrl" value="${bundle.kappLocation}/${form.slug}?kapp=${text.escape(param.kapp)}&slug=${text.escape(param.slug)}" scope="request" />
<c:if test="${text.isNotBlank(param.slug)}">
    <%-- Get Translation Snapshot for the Translation Kapp --%>
    <c:set var="i18nKapp" value="${space.getKapp(param.slug)}" scope="request" />
    <c:set var="translationSnapshot" scope="request"
           value="${translationManager.getSnapshot(i18nKapp)}" />

    <%-- Get entries --%>
    <c:choose>
        <%--If context exists--%>
        <c:when test="${text.isNotBlank(param.context)}">
            <%-- Get context pack --%>
            <c:set var="translationContextPack" scope="request"
                   value="${translationSnapshot.getContextPack(i18nKapp, param.context)}" />

            <c:choose>
                <%--If key exists, get by key--%>
                <c:when test="${text.isNotBlank(param.key)}">
                    <c:choose>
                        <%--If getting all--%>
                        <c:when test="${param.missing eq null}">
                            <c:set var="entries" scope="request"
                                   value="${translationContextPack.getEntriesByKey(param.key)}"/>
                        </c:when>
                        <%--If getting missing--%>
                        <c:otherwise>
                            <c:set var="entries" scope="request"
                                   value="${translationContextPack.getMissingEntriesByKey(param.key)}"/>
                        </c:otherwise>
                    </c:choose>
                    <c:set var="keyColumn" scope="request" value="${false}"/>
                </c:when>
                <%--If locale exists, get by locale--%>
                <c:when test="${text.isNotBlank(param.locale)}">
                    <c:choose>
                        <%--If getting all--%>
                        <c:when test="${param.missing eq null}">
                            <c:set var="entries" scope="request"
                                   value="${translationContextPack.getEntriesByLocale(param.locale)}"/>
                        </c:when>
                        <%--If getting missing--%>
                        <c:otherwise>
                            <c:set var="entries" scope="request"
                                   value="${translationContextPack.getMissingEntriesByLocale(param.locale)}"/>
                        </c:otherwise>
                    </c:choose>
                </c:when>
                <%--Otherwise, get all by context--%>
                <c:otherwise>
                    <c:choose>
                        <%--If getting all--%>
                        <c:when test="${param.missing eq null}">
                            <c:set var="entries" scope="request"
                                   value="${translationContextPack.getEntries()}"/>
                        </c:when>
                        <%--If getting missing--%>
                        <c:otherwise>
                            <c:set var="entries" scope="request"
                                   value="${translationContextPack.getMissingEntries()}"/>
                        </c:otherwise>
                    </c:choose>
                </c:otherwise>
            </c:choose>
        </c:when>
        <%--If locale exists--%>
        <c:when test="${text.isNotBlank(param.locale)}">
            <c:choose>
                <%--If getting all--%>
                <c:when test="${param.missing eq null}">
                    <c:set var="entries" scope="request"
                           value="${translationSnapshot.getEntriesByLocale(i18nKapp, param.locale)}"/>
                </c:when>
                <%--If getting missing--%>
                <c:otherwise>
                    <c:set var="entries" scope="request"
                           value="${translationSnapshot.getMissingEntriesByLocale(i18nKapp, param.locale)}"/>
                </c:otherwise>
            </c:choose>
            <c:set var="contextColumn" scope="request" value="${true}"/>
        </c:when>
        <%--Otherwise, get all--%>
        <c:otherwise>
            <c:choose>
                <%--If getting all--%>
                <c:when test="${param.missing eq null}">
                    <c:set var="entries" scope="request"
                           value="${translationSnapshot.getEntries(i18nKapp)}"/>
                </c:when>
                <%--If getting missing--%>
                <c:otherwise>
                    <c:set var="entries" scope="request"
                           value="${translationSnapshot.getMissingEntries(i18nKapp)}"/>
                </c:otherwise>
            </c:choose>
            <c:set var="contextColumn" scope="request" value="${true}"/>
        </c:otherwise>
    </c:choose>
</c:if>

<json:object>
    <json:array name="columns">
        <json:object>
            <json:property name="title" value="Locale"/>
            <json:property name="data" value="locale"/>
            <json:property name="class" value="locale"/>
            <json:property name="width" value="10%"/>
        </json:object>
        <c:if test="${contextColumn eq true}">
            <json:object>
                <json:property name="title" value="Context"/>
                <json:property name="data" value="context"/>
                <json:property name="class" value="context"/>
                <json:property name="width" value="15%"/>
            </json:object>
        </c:if>
        <c:if test="${keyColumn ne false}">
            <json:object>
                <json:property name="title" value="Key"/>
                <json:property name="data" value="key"/>
                <json:property name="class" value="key ellipsis"/>
            </json:object>
        </c:if>
        <json:object>
            <json:property name="title" value=""/>
            <json:property name="class" value="references"/>
            <json:property name="orderable" value="${false}"/>
            <json:property name="searchable" value="${false}"/>
            <json:property name="defaultContent" value=""/>
            <json:property name="width" value="3%"/>
        </json:object>
        <json:object>
            <json:property name="title" value="Translation"/>
            <json:property name="data" value="value"/>
            <json:property name="class" value="translation ellipsis"/>
        </json:object>
        <json:object>
            <json:property name="title" value=""/>
            <json:property name="orderable" value="${false}"/>
            <json:property name="searchable" value="${false}"/>
            <json:property name="class" value="actions"/>
            <json:property name="defaultContent" value="<div class=\"btn-group pull-right\" role=\"group\"><button class=\"edit-translation-btn btn btn-xs btn-default\" type=\"button\"><span class=\"fa fa-pencil\"></span></button><button class=\"delete-translation-btn btn btn-xs btn-danger\" type=\"button\"><span class=\"fa fa-times\"></span></button></div>"/>
            <json:property name="width" value="8%"/>
        </json:object>
    </json:array>
    <json:array name="data">
        <c:if test="${param.add eq null}">
            <c:forEach var="entry" items="${entries}">
                <json:object>
                    <json:property name="locale" value="${entry.localeCode}"/>
                    <json:property name="context" value="${entry.contextName}"/>
                    <json:property name="key" value="${entry.key}"/>
                    <json:property name="value" value="${entry.value}"/>
                    <json:property name="language" value="${entry.getLocale().name}"/>
                    <json:property name="inherited" value="${entry.isVirtual()}"/>
                    <json:property name="sourceContext" value="${entry.isVirtual() ? entry.sourceEntry.contextName : ''}"/>
                    <json:property name="sourceLocale" value="${entry.isVirtual() ? entry.sourceEntry.localeCode : ''}"/>
                    <json:property name="missing" value="${empty entry.value && !entry.localeCode.startsWith(translationSnapshot.defaultLocaleCode)}"/>
                    <json:property name="byLocale" value="${text.isNotBlank(param.locale)}"/>
                    <json:property name="i18nKappUrl" value="${i18nKappUrl}"/>
                    <json:property name="references" value="${translationContextPack.getReferences(entry.key)}"/>
                    <%--<json:property name="dependencyCount" value="${translationSnapshot.getDependentEntries(i18nKapp, entry.contextName, entry.localeCode, entry.key).size()}"/>--%>
                    <json:property name="virtual" value="${empty entry.id}"/>
                </json:object>
            </c:forEach>
        </c:if>
    </json:array>
</json:object>