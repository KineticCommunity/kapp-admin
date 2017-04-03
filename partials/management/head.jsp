<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<bundle:stylepack>
    <bundle:style src="${bundle.location}/css/management/management.css"/>
    <bundle:style src="${bundle.location}/css/management/categories.css"/>
    <bundle:style src="${bundle.location}/libraries/bootstrap-colorpicker/css/bootstrap-colorpicker.min.css"/>
    <bundle:style src="${bundle.location}/libraries/fontawesome-iconpicker/css/fontawesome-iconpicker.min.css"/>
</bundle:stylepack>

<bundle:scriptpack>
    <bundle:script src="${bundle.location}/js/management/management.js" />
    <bundle:script src="${bundle.location}/js/management/submissionsDataTable.js" />
    <bundle:script src="${bundle.location}/libraries/bootstrap-colorpicker/js/bootstrap-colorpicker.min.js" />
    <bundle:script src="${bundle.location}/libraries/fontawesome-iconpicker/js/fontawesome-iconpicker.min.js" />
</bundle:scriptpack>