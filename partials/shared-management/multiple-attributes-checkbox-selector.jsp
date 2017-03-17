<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<div class="multiAttributes m-b-2" name="${thisAttribute.name}">
    <label class="control-label">${i18n.translate(thisAttribute.name)}</label>
    <span id="helpBlock-${thisAttribute.name}" class="help-block">${thisAttribute.description}</span>
    <c:forEach items="${attributeDefs}" var="attrDef">
        <c:set var="checked" value="${null}"/>
        <c:forEach var="currentValue" items="${currentObj.getAttributeValues(thisAttribute.name)}">
            <c:if test="${attrDef.name eq currentValue}">
                <c:set var="checked" value="checked"/>
            </c:if>
        </c:forEach>
        <div class="checkbox">
          <label>
            <input name="${thisAttribute.name}" type="checkbox" ${checked} value="${attrDef.name}">${attrDef.name}
          </label>
        </div>
    </c:forEach>
</div>