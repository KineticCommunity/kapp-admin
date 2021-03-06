<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<bundle:stylepack>
    <bundle:style src="${bundle.location}/css/translations/translations.css"/>
</bundle:stylepack>
<bundle:scriptpack>
    <bundle:script src="${bundle.location}/js/translations/translations.js" />
</bundle:scriptpack>
<script>
    bundle.adminTranslations.apiBaseUrl = "${bundle.spaceLocation}/app/apis/translations/v1/kapps/${i18nKapp.slug}";
    bundle.adminTranslations.i18nKappUrl = "${i18nKappUrl}";
</script>