<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<bundle:layout page="../../layouts/form.jsp">
    <section class="page" data-page="${page.name}">
        <c:import url="${bundle.path}/partials/notifications/dynamicValues.jsp" charEncoding="UTF-8"/>
        <app:bodyContent/>
    </section>
</bundle:layout>