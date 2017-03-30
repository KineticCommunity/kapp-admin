<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<c:choose>
    <c:when test="${not empty kapp.getForm('registered-images')}">
        <c:set var="images" value="${AdminHelper.getRegisteredImages()}" scope="request" />

        <div class="attribute m-b-2">
            <label class="control-label">${i18n.translate(thisAttribute.name)}</label>
            <span id="helpBlock-${thisAttribute.name}" class="help-block">${thisAttribute.description}</span>
            <select name="${thisAttribute.name}" class="attributeValue form-control" value="
            ${currentObj.getAttributeValue(thisAttribute.name)}">
                <option/>
                <c:forEach items="${images}" var="image">
                    <c:set var="selected" value=""/>
                    <c:if test="${image.url eq currentObj.getAttributeValue(thisAttribute.name)}">
                        <c:set var="selected" value="selected"/>
                    </c:if>
                    <option ${selected} value="${image.url}">${image.name}</option>
                </c:forEach>
            </select>

            <span id="helpBlock-${thisAttribute.name}" class="help-block">
                ${i18n.translate('To Add More Images, click here.')}
                <a href="${bundle.kappLocation}/datastore?page=datastore/record&store=registered-images">
                    <i class="fa fa-gear"></i>
                </a>
            </span>
        </div>
    </c:when>

    <c:otherwise>
        <c:import url="${bundle.path}/partials/management/plaintext-input.jsp" charEncoding="UTF-8" />
    </c:otherwise>

</c:choose>