<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="bundle/initialization.jspf" %>

<bundle:layout page="layouts/layout.jsp">
    <!-- Sets title and imports js and css specific to this console. -->
    <bundle:variable name="pageTitle">${text.escape(form.name)}</bundle:variable>
    <bundle:variable name="head">
        <app:formHeadContent/>
    </bundle:variable>
    
    <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
    <section class="page" data-page="${page.name}">
        <div class="page-header">
            <h3>${text.escape(form.name)}</h3>
        </div>
        <c:if test="${param.review != null && pages.size() > 1}">
            <c:import url="partials/review.jsp" charEncoding="UTF-8"></c:import>
        </c:if>
        <div class="errors"></div>
        <app:bodyContent/>
    </section>
    <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>

</bundle:layout>
