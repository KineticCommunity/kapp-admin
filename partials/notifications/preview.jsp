<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<c:catch><c:set var="submission" value="${Submissions.retrieve(param.id)}" scope="request"/></c:catch>
<c:choose>
    <c:when test="${not empty submission}">
        ${text.replaceRegex(submission.getValue('HTML Content'), '\\$\\{(.*?)\\}', ' <span style=\'background-color:rgba(255,255,0,0.20)\'>$0</span>')}
    </c:when>
    <c:otherwise>
        <h5 class="text-center">Error loading preview</h5>
    </c:otherwise>
</c:choose>
