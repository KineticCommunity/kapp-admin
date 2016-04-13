<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<bundle:stylepack>
    <bundle:style src="${bundle.location}/css/${not empty form ? form.slug : ''}/categories.css"/>
</bundle:stylepack>
<bundle:scriptpack>
    <bundle:script src="${bundle.location}/js/${not empty form ? form.slug : ''}/categories.js" />
</bundle:scriptpack>