<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<div class="attribute m-b-2">
    <label class="control-label">${i18n.translate(thisAttribute.name)}</label>
    <span id="helpBlock-${thisAttribute.name}" class="help-block">${thisAttribute.description}</span>
    <select name="${thisAttribute.name}" class="attributeValue form-control" value="${currentObj.getAttributeValue(thisAttribute.name)}">
        <option/>
        <c:forEach items="${space.teams}" var="team">
            <c:if test="${not fn:startsWith(fn:toLowerCase(team.name), 'role')}">
                <c:set var="selected" value=""/>
                <c:if test="${team.name eq currentObj.getAttributeValue(thisAttribute.name)}">
                    <c:set var="selected" value="selected"/>
                </c:if>
                <option ${selected} value="${team.name}">${team.name}</option>
            </c:if>
        </c:forEach>
    </select>
</div>