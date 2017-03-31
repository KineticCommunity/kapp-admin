<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../bundle/initialization.jspf" %>

<div class="container text-center">
    <h4>You seem to have take a wrong turn.</h4>
    <p>${param.message}</p>
    <p><a href="javascript:window.history.back();">Return to previous page.</a></p>
</div>