<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../../bundle/initialization.jspf" %>

<div data-attribute="${definitionObject.name}">
    <label class="field-label">
        <span id="label-${definitionObject.name}">${i18n.translate(param.label)}</span>
        <i class="small" id="description-${definitionObject.name}">${i18n.translate(definitionObject.description)}</i>
    </label>
    <c:if test="${dataObject.get('_default') != null}">
        <c:forEach items="${dataObject}" var="option">
            <c:if test="${empty selectedRadio && text.equals(option.value, attributeObject.value)}">
                <c:set var="selectedRadio" value="${option.value}" />
            </c:if>
        </c:forEach>
        <c:if test="${empty selectedRadio}">
            <c:set var="selectedRadio" value="${dataObject.get('_default')}" />
        </c:if>
    </c:if>
    <c:forEach items="${dataObject}" var="option">
        <c:if test="${not text.equals(option.key, '_default')}">
            <span class="radio-label">
                <input type="radio" aria-describedby="description-${definitionObject.name}" aria-labelledby="label-${definitionObject.name}" 
                       id="${definitionObject.name}-${option.value}" name="${definitionObject.name}" value="${option.value}"
                       ${text.equals(option.value, selectedRadio) ? 'checked' : ''}>
                <label class="label label-default" for="${definitionObject.name}-${option.value}">
                    <span>${option.key}</span>
                </label>
            </span>
        </c:if>
    </c:forEach>
</div>