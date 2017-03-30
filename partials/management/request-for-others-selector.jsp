<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<div class="attribute m-b-2">
    <label class="control-label">${i18n.translate("Allow Users to Request for Others")}</label>
    <span id="helpBlock-${thisAttribute.name}" class="help-block">${thisAttribute.description}</span>
    <select name="${thisAttribute.name}" class="attributeValue form-control" value="${currentObj.getAttributeValue(thisAttribute.name)}">
        <option/>
        <option ${currentObj.getAttributeValue(thisAttribute.name) eq 'Yes' ? 'selected' : null} value="Yes">${i18n.translate("Yes")}</option>
        <option ${currentObj.getAttributeValue(thisAttribute.name) ne 'Yes' ? 'selected' : null} value="${null}">${i18n.translate("No")}</option>
    </select>
</div>