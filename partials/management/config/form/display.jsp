<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../../../bundle/initialization.jspf" %>

<c:set var="currentKapp" value="${space.getKapp(param.kapp)}" />
<c:set var="currentForm" value="${currentKapp.getForm(param.form)}" />
<c:set var="adminKapp" value="${space.getKapp(space.getAttributeValue('Admin Kapp Slug'))}" scope="request" />
<c:set var="catalogKapp" value="${space.getKapp(space.getAttributeValue('Catalog Kapp Slug'))}" scope="request" />
<c:set var="queueKapp" value="${space.getKapp(space.getAttributeValue('Queue Kapp Slug'))}" scope="request" />


<%-- Define list of form attributes that should appear in the Display Options tab.
     Each attribute is a JSON object with the following properties:
        name:     Attribute name.
        label:    Optional label to display instead of attribute name.
        partial:  Filename of the partial used to render this attribute inside the partials/management/attributes folder.
        data:     JSON object used to pass extra data or field options for checkboxes, selects, etc.
                  For options, the property name is the label to display and the property value is the value to be saved. --%>
<c:set var="tabAttributes">
    <json:array>
        <json:object>
            <json:property name="name" value="Request For Others" />
            <json:property name="label" value="Allow Users to Request For Others" />
            <json:property name="partial" value="radioInput.jsp" />
            <json:object name="data">
                <json:property name="Yes" value="Yes" />
                <json:property name="No" value="" />
            </json:object>
        </json:object>
        <json:object>
            <json:property name="name" value="Icon" />
            <json:property name="partial" value="iconInput.jsp" />
        </json:object>
        <json:object>
            <json:property name="name" value="Owning Team" />
            <json:property name="partial" value="selectMultiple.jsp" />
            <json:object name="data">
                <c:forEach var="o" items="${TeamsHelper.teams}">
                    <json:property name="${o.name}" value="${o.name}" />
                </c:forEach>
            </json:object>
        </json:object>
    </json:array>
</c:set>

<%-- Display Options tab HTML --%>
<div data-property="description">
    <label class="field-label">
        <span id="label-form-description">${i18n.translate('Form Description')}</span>
        <i class="small" id="description-form-description">${i18n.translate('Helps users find the form they\'re looking for.')}</i>
    </label>
    <textarea aria-describedby="description-form-description" aria-labelledby="label-form-description" 
              name="form-description" class="form-control">${currentForm.description}</textarea>
</div>

<c:forEach var="attr" items="${json.parse(tabAttributes)}">
    <c:set var="definitionObject" value="${currentKapp.getFormAttributeDefinition(attr.name)}" scope="request" />
    <c:if test="${not empty definitionObject}">
        <c:set var="attributeObject" value="${currentForm.getAttribute(attr.name)}" scope="request" />
        <c:set var="dataObject" value="${attr.data}" scope="request" />
        <c:import url="${bundle.path}/partials/management/attributes/${attr.partial}" charEncoding="UTF-8">
            <c:param name="label" value="${text.defaultIfBlank(attr.label, attr.name)}"/>
        </c:import>
        <c:remove var="attributeObject" />
        <c:remove var="dataObject" />
    </c:if>
    <c:remove var="definitionObject" />
</c:forEach>

<div class="m-y-2 text-right">
    <button data-save-button class="btn btn-success">
        <span class="fa fa-check fa-fw"></span>
        <span>Update Display Options</span>
    </button>
    <button data-reset-button class="btn btn-link">
        <span>Reset</span>
    </button>
</div>