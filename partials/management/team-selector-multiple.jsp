<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<div class="multiAttributes m-b-2" name="${thisAttribute.name}">
    <label class="control-label">${i18n.translate(thisAttribute.name)}</label>
    <span id="helpBlock-${thisAttribute.name}" class="help-block">${thisAttribute.description}</span>
    <select multiple class="form-control">
        <c:forEach items="${space.teams}" var="team">
            <c:if test="${not fn:startsWith(fn:toLowerCase(team.name), 'role')}">
                <c:set var="selected" value="${null}"/>
                <c:forEach var="currentValue" items="${currentObj.getAttributeValues(thisAttribute.name)}">
                    <c:if test="${team.name eq currentValue}">
                        <c:set var="selected" value="selected"/>
                    </c:if>
                </c:forEach>
                <option ${selected} value="${team.name}">${team.name}</option>
            </c:if>
        </c:forEach>
    </select>
</div>