<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../../bundle/initialization.jspf" %>

<div data-attribute="${definitionObject.name}">
    <label class="field-label">
        <span id="label-${definitionObject.name}">${i18n.translate(param.label)}</span>
        <i class="small" id="description-${definitionObject.name}">${i18n.translate(definitionObject.description)}</i>
    </label>
    <c:set var="valueMap">
        <json:object>
            <c:forEach items="${attributeObject.values}" var="value">
                <json:property name="${value}" value="${true}" />
            </c:forEach>
        </json:object>
    </c:set>
    <c:set var="values" value="${json.parse(valueMap)}" />
    <c:forEach items="${dataObject}" var="option">
        <span class="checkbox-label">
            <input type="checkbox" aria-describedby="description-${definitionObject.name}" aria-labelledby="label-${definitionObject.name}" 
                   id="${definitionObject.name}-${option.value}" name="${definitionObject.name}" value="${option.value}"
                   ${values[option.value] ? 'checked' : ''}>
            <label class="label label-default" for="${definitionObject.name}-${option.value}">
                <span>${option.key}</span>
            </label>
        </span>
    </c:forEach>
</div>