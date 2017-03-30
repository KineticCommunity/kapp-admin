<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<c:choose>
    <c:when test="${not empty kapp.getForm('notification-data')}">
        <c:set var="notifications" value="${AdminHelper.getNotificationTemplates()}" scope="request" />

        <div class="attribute m-b-2">
            <label class="control-label">${i18n.translate(thisAttribute.name)}</label>
            <span id="helpBlock-${thisAttribute.name}" class="help-block">${thisAttribute.description}</span>
            <select name="${thisAttribute.name}" class="attributeValue form-control" value="
            ${currentObj.getAttributeValue(thisAttribute.name)}">
                <option/>
                <c:forEach items="${notifications}" var="nofification">
                    <c:set var="selected" value=""/>
                    <c:if test="${nofification.name eq currentObj.getAttributeValue(thisAttribute.name)}">
                        <c:set var="selected" value="selected"/>
                    </c:if>
                    <option ${selected} value="${nofification.name}">${nofification.name}</option>
                </c:forEach>
            </select>

            <span id="" class="help-block">
                ${i18n.translate('To Add More Notifications, click here.')}
                <a href="${bundle.kappLocation}/notifications">
                    <i class="fa fa-gear"></i>
                </a>
            </span>
        </div>
    </c:when>

    <c:otherwise>
        <c:import url="${bundle.path}/partials/management/plaintext-input.jsp" charEncoding="UTF-8" />
    </c:otherwise>

</c:choose>