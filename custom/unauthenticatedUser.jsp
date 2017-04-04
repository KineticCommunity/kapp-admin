<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../bundle/initialization.jspf" %>
<bundle:layout page="../layouts/form.jsp">
    <section class="page" data-page="${page.name}">
        <app:bodyContent/>
        <script src="${i18n.scriptPath('shared')}"></script>
        <script src="${i18n.scriptPath('bundle')}"></script>
        <script src="${i18n.scriptPath(form)}"></script>
    </section>
</bundle:layout>