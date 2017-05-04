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
    <select multiple aria-describedby="description-${definitionObject.name}" aria-labelledby="label-${definitionObject.name}" 
            name="${definitionObject.name}" value="${attributeObject.values}">
        <c:forEach items="${dataObject}" var="option">
            <c:if test="${values[option.value]}"><c:set var="selected" value="${empty selected ? 1 : selected + 1}"/></c:if>
            <option value="${option.value}" ${values[option.value] ? 'selected' : ''}>${option.key}</option>
        </c:forEach>
    </select>
    <c:if test="${not empty attributeObject.value && (empty selected || selected < fn:length(attributeObject.values))}">
        <small class="text-danger">
            <span class="fa fa-exclamation-triangle"></span>
            <span>One or more of the currently stored values (not shown) is not a valid option</span>
        </small>
    </c:if>
</div>