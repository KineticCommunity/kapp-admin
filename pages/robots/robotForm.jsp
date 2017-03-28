<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<c:set var="isEmbedded" value="${param.embedded != null}" scope="request"/>
<bundle:layout page="../../layouts/form.jsp">
    <section class="page ${isEmbedded ? 'embedded' : ''}" data-page="${page.name}">
        <app:bodyContent/>
    </section>
</bundle:layout>
