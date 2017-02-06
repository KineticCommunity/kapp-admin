<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<bundle:layout page="../../layouts/layout.jsp">
    <bundle:variable name="head">
	   <c:import url="${bundle.path}/partials/notifications/details_head.jsp" charEncoding="UTF-8"/>
        <app:formHeadContent/>
    </bundle:variable>
    <section class="page" data-page="${page.name}">
        <app:bodyContent/>
    </section>
</bundle:layout>
