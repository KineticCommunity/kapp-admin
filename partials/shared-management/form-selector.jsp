<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<div class="attribute m-b-2">
    <label class="control-label">${i18n.translate(fn:substringBefore(thisAttribute.name, 'Slug'))} Name</label>
    <span id="helpBlock-${thisAttribute.name}" class="help-block">${thisAttribute.description}</span>
    <select name="${thisAttribute.name}" class="attributeValue form-control" value="${currentObj.getAttributeValue(thisAttribute.name)}">
        <option/>
        <c:forEach items="${space.getKapp(space.getAttributeValue('Queue Kapp Slug')).forms}" var="form">
            <c:set var="selected" value=""/>
            <c:if test="${form.slug eq currentObj.getAttributeValue(thisAttribute.name)}">
                <c:set var="selected" value="selected"/>
            </c:if>
            <option ${selected} value="${form.slug}">${form.name}</option>
        </c:forEach>
    </select>
</div>