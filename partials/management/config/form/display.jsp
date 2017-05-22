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
<div class="row">
    <div class="col-sm-6" data-property="status">
        <label class="field-label">
            <span id="label-form-status">${i18n.translate('Form Status')}</span>
        </label>
        <select aria-labelledby="label-form-status" name="form-status" class="form-control">
            <option value="New" ${text.equals(currentForm.status, 'New') ? 'selected' : ''}>New</option>
            <option value="Active" ${text.equals(currentForm.status, 'Active') ? 'selected' : ''}>Active</option>
            <option value="Inactive" ${text.equals(currentForm.status, 'Inactive') ? 'selected' : ''}>Inactive</option>
            <option value="Delete" ${text.equals(currentForm.status, 'Delete') ? 'selected' : ''}>Delete</option>
        </select>
    </div>
    <div class="col-sm-6" data-property="type">
        <label class="field-label">
            <span id="label-form-type">${i18n.translate('Form Type')}</span>
        </label>
        <select aria-labelledby="label-form-type" name="form-type" class="form-control">
            <option value=""></option>
            <c:forEach var="type" items="${currentKapp.formTypes}">
                <option value="${type.name}" ${text.equals(currentForm.type.name, type.name) ? 'selected' : ''}>${type.name}</option>
            </c:forEach>
        </select>
    </div>
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