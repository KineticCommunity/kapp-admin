<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<bundle:layout page="../../layouts/form.jsp">
    <section class="page" data-page="${page.name}">
        <c:import url="${bundle.path}/partials/notifications/dynamicValues.jsp" charEncoding="UTF-8"/>
        <app:bodyContent/>
    </section>

    <!-- HIDDEN DIV ELEMENT USED FOR COLLECTING LANGUAGES AND POPULATING THE DROP DOWN FIELD ON THE FORM -->
    <div class="hidden">
    	<select id="temp-locales" class="form-control input-sm">
            <option></option>
            <c:forEach var="optionLocale" items="${i18n.getSystemLocales(pageContext.request.locales)}">
                <option value="${i18n.getLocaleCode(optionLocale)}">${text.escape(i18n.getLocaleNameGlobalized(optionLocale))}</option>
            </c:forEach>
        </select>
    </div>
</bundle:layout>