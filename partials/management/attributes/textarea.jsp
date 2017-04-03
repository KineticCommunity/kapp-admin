<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../../bundle/initialization.jspf" %>

<div data-attribute="${definitionObject.name}">
    <label class="field-label">
        <span id="label-${definitionObject.name}">${i18n.translate(param.label)}</span>
        <i class="small" id="description-${definitionObject.name}">${i18n.translate(definitionObject.description)}</i>
    </label>
    <textarea aria-describedby="description-${definitionObject.name}" aria-labelledby="label-${definitionObject.name}" 
              name="${definitionObject.name}" class="form-control">${attributeObject.value}</textarea>
</div>