<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../../bundle/initialization.jspf" %>
<c:choose>
    <c:when test="${not empty kapp.getForm('notification-data')}">
        <c:set var="notifications" value="${AdminHelper.getNotificationTemplates()}" />

        <div data-attribute="${definitionObject.name}">
            <label class="field-label">
                <span id="label-${definitionObject.name}">${i18n.translate(param.label)}</span>
                <i class="small" id="description-${definitionObject.name}">${i18n.translate(definitionObject.description)}</i>
            </label>
            <select aria-describedby="description-${definitionObject.name}" aria-labelledby="label-${definitionObject.name}" 
                    name="${definitionObject.name}" class="form-control" value="${attributeObject.value}">
                <option/>
                <c:forEach items="${notifications}" var="notification">
                    <option value="${notification.name}" ${text.equals(notification.name, attributeObject.value) ? 'selected' : ''}>${notification.name}</option>
                </c:forEach>
            </select>
            <small class="text-right display-block">
                <a href="${bundle.kappLocation}/notifications">Add More Notifications</a>
            </small>
        </div>
    </c:when>
    <c:otherwise>
        <c:import url="${bundle.path}/partials/management/attributes/textInput.jsp" charEncoding="UTF-8" />
    </c:otherwise>
</c:choose>