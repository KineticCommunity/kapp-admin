<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="bundle/initialization.jspf" %>
<c:set var="includeHeaderTall" value="${true}" scope="request"/>
<c:set var="removeBreadcrumb" value="${true}" scope="request"/>
<bundle:layout page="${bundle.path}/layouts/submissionSupportLayout.jsp">
    <link rel="stylesheet" href="${bundle.location}/../request-ce-kinops-catalog/css/master.css">
    <div data-ng-app="kd.bundle.angular">
        <app />
    </div>
    <script src="${bundle.location}/js/submissionSupport.bundle.js"></script>
</bundle:layout>
