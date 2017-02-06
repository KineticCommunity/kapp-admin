<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<bundle:stylepack>
    <bundle:style src="${bundle.location}/css/notifications/notification_templates.css"/>
	<bundle:style src="${bundle.location}/libraries/ckeditor/contents.css"/>
</bundle:stylepack>
<bundle:scriptpack>
    <bundle:script src="${bundle.location}/js/notifications/notifications.js" />
	<bundle:script src="${bundle.location}/libraries/ckeditor/ckeditor.js" />
	<bundle:script src="${bundle.location}/js/notifications/notification_templates.js" />
</bundle:scriptpack>
