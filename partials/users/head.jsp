<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<bundle:stylepack>
    <bundle:style src="${bundle.location}/css/users/users.css"/>
</bundle:stylepack>
<bundle:scriptpack>
    <bundle:script src="${bundle.location}/js/users/users.js" />
</bundle:scriptpack>
<script>
    bundle.adminUsers.consoleSlug = "${form.slug}";
</script>