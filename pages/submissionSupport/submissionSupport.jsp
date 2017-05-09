<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<c:set var="removeBreadcrumb" value="${true}" scope="request"/>

<%-- Here we check for a request header that tells us whether or not the request was made via webpack proxy server.
 If it is we do not want to use the bundle location in the static path because the webpack dev server will be
 serving resources from /static.  If the header is not present we want to prefix the /static path with the
 bundle location because that is where they will be served from the core web server. --%>
<c:set var="bundlePath" value="${empty pageContext.request.getHeader('X-From-Webpack-Proxy') ? bundle.location : '' }" />


<bundle:layout page="${bundle.path}/layouts/submissionSupportLayout.jsp">
    <bundle:variable name="kappName">Submission Support</bundle:variable>
    <bundle:variable name="kappLink">${bundle.spaceLocation}/${kapp.slug}/submission-support</bundle:variable>
    <link rel="stylesheet" href="${bundle.location}/../catalog/css/master.css">
    <div data-ng-app="kd.bundle.angular">
        <app />
    </div>
    <script src="${bundlePath}/js/submissionSupport.bundle.js"></script>
</bundle:layout>
