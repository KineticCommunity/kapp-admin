<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<bundle:stylepack>
    <bundle:style src="${bundle.location}/css/notifications/notifications.css"/>
</bundle:stylepack>
<bundle:scriptpack>
    <bundle:script src="${bundle.location}/js/notifications/notifications.js" />
</bundle:scriptpack>
<script>
    bundle.notifications.consoleSlug = "${form.slug}";
    bundle.notifications.kappSlug = "${kapp.slug}";
</script>