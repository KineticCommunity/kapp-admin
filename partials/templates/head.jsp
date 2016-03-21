<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<bundle:stylepack>
    <bundle:style src="${bundle.location}/css/${currentConsole.slug}/templates.css"/>
</bundle:stylepack>
<bundle:scriptpack>
    <bundle:script src="${bundle.location}/js/${currentConsole.slug}/templates.js" />
</bundle:scriptpack>