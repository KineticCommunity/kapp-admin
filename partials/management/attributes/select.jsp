<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../../bundle/initialization.jspf" %>

<div data-attribute="${definitionObject.name}">
    <label class="field-label">
        <span id="label-${definitionObject.name}">${i18n.translate(param.label)}</span>
        <i class="small" id="description-${definitionObject.name}">${i18n.translate(definitionObject.description)}</i>
    </label>
    <select aria-describedby="description-${definitionObject.name}" aria-labelledby="label-${definitionObject.name}" 
            name="${definitionObject.name}" value="${attributeObject.value}">
        <option />
        <c:forEach items="${dataObject}" var="option">
            <c:if test="${text.equals(option.value, attributeObject.value)}"><c:set var="selected" value="${true}"/></c:if>
            <option value="${option.value}" ${text.equals(option.value, attributeObject.value) ? 'selected' : ''}>${option.key}</option>
        </c:forEach>
        <c:if test="${not empty attributeObject.value && not selected}">
            <option value="${attributeObject.value}" selected disabled>${attributeObject.value}</option>
        </c:if>
    </select>
    <c:if test="${not empty attributeObject.value && not selected}">
        <small class="text-danger">
            <span class="fa fa-exclamation-triangle"></span>
            <span>The currently stored value <strong>${attributeObject.value}</strong> is not a valid option</span>
        </small>
    </c:if>
</div>