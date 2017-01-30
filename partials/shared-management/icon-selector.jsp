<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<div class="attribute m-b-2">
    <label class="control-label">${i18n.translate(thisAttribute.name)}</label>
    <span id="helpBlock-${thisAttribute.name}" class="help-block">${thisAttribute.description}</span>
    
    <div class="input-group iconpicker-container">
        <input name=${thisAttribute.name} data-placement="bottomRight" class="attributeValue form-control icp icp-auto iconpicker-element iconpicker-input" value="${currentObj.getAttributeValue(thisAttribute.name)}" type="text">
        <span class="input-group-addon">
            <i class="fa ${currentObj.getAttributeValue(thisAttribute.name)}"></i>
        </span>
    </div>
</div>