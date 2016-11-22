<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="bundle/initialization.jspf" %>

<bundle:layout page="layouts/layout.jsp">
    <!-- Sets title and imports js and css specific to this console. -->
    <bundle:variable name="head">
        <app:formHeadContent/>
    </bundle:variable>
    
    <!-- BREADCRUMBS START HERE. Remove if not needed. ------------------------------------------->
    <bundle:variable name="breadcrumb">
        <c:forEach items="${AdminHelper.getFormDefinedConsoleBreadcrumbs(form)}" var="breadcrumb" varStatus="status">
            <c:choose>
                <c:when test="${!status.last}">
                    <li><a href="${breadcrumb.href}">${breadcrumb.name}</a></li>
                </c:when>
                <c:otherwise>
                    <li class="active">${breadcrumb.name}</li>
                </c:otherwise>
            </c:choose>
        </c:forEach>
    </bundle:variable>
    <!-- BREADCRUMBS END HERE. ------------------------------------------------------------------->
    
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
