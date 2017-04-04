<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<%@include file="../../bundle/router.jspf" %>
<c:set var="isEmbedded" value="${param.embedded != null}" scope="request"/>

<bundle:layout page="../../layouts/form.jsp">
    <bundle:variable name="head">
        <bundle:variable name="pageTitle">${text.escape(i18n.translate(form.name))}</bundle:variable>
    </bundle:variable>

    <c:if test="${not isEmbedded}">
        <%-- BREADCRUMBS START HERE. Remove if not needed. -------------------------------------------%>
        <bundle:variable name="breadcrumb">
            <li>${text.escape(i18n.translate('Utilities'))}</li>
            <li class="active">${text.escape(i18n.translate(form.name))}</li>
        </bundle:variable>
        <%-- BREADCRUMBS END HERE. -------------------------------------------------------------------%>

        <div class="page-header">
            <h3>${text.escape(form.name)}</h3>
        </div>
    </c:if>
    
    <section class="page ${isEmbedded ? 'embedded' : ''}" data-page="${page.name}">
        <c:if test="${param.review != null && pages.size() > 1}">
            <c:import url="../../partials/review.jsp" charEncoding="UTF-8"></c:import>
        </c:if>
        <div class="errors"></div>
        <app:bodyContent/>
    </section>
</bundle:layout>
