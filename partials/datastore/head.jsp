<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<bundle:stylepack>
    <bundle:style src="${bundle.location}/css/datastore/datastore.css"/>
</bundle:stylepack>
<bundle:scriptpack>
    <bundle:script src="${bundle.location}/js/datastore/datastore.js" />
    <bundle:script src="${bundle.location}/js/datastore/datastoreStore.js" />
</bundle:scriptpack>
<script>
    bundle.adminDatastore.consoleSlug = "${form.slug}";
    bundle.adminDatastore.kappSlug = "${kapp.slug}";
</script>