<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<div id="teamAssigneeId" class="attribute m-b-2" style="display:none;">
    <label class="control-label">${i18n.translate("Task Assignee")}</label>
    <span id="helpBlock-${thisAttribute.name}" class="help-block">${thisAttribute.description}</span>
    <select name="${thisAttribute.name}" class="attributeValue form-control" value="${currentObj.getAttributeValue(thisAttribute.name)}">
        <option/>
    </select>
</div>