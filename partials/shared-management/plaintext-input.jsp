<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<div class="attribute m-b-2">
	<label class="control-label">${i18n.translate(thisAttribute.name)}</label>
	<span id="helpBlock-${thisAttribute.name}" class="help-block">${thisAttribute.description}</span>
	<input aria-describedby="helpBlock-${thisAttribute.name}" type="text" name="${thisAttribute.name}" class="attributeValue form-control" value="${currentObj.getAttributeValue(thisAttribute.name)}">
</div>