<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<div class="attribute m-b-2">
    <label class="control-label">${i18n.translate(thisAttribute.name)}</label>
    <span id="helpBlock-${thisAttribute.name}" class="help-block">${currentKapp.getFormAttributeDefinition(thisAttribute.name).description}</span>
    <select name="${thisAttribute.name}" class="attributeValue form-control" value="${currentObj.getAttributeValue(thisAttribute.name)}">
        <option/>
        <c:forEach items="${groupList}" var="group">
            <c:set var="selected" value=""/>
            <c:if test="${group.name eq currentObj.getAttributeValue(thisAttribute.name)}">
                <c:set var="selected" value="selected"/>
            </c:if>
            <option ${selected} value="${group.name}">${group.name}</option>
        </c:forEach>
    </select>
</div>