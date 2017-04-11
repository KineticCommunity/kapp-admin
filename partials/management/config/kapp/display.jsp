<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../../../bundle/initialization.jspf" %>

<c:set var="currentKapp" value="${space.getKapp(param.kapp)}" />
<c:set var="adminKapp" value="${space.getKapp(space.getAttributeValue('Admin Kapp Slug'))}" scope="request" />
<c:set var="catalogKapp" value="${space.getKapp(space.getAttributeValue('Catalog Kapp Slug'))}" scope="request" />
<c:set var="queueKapp" value="${space.getKapp(space.getAttributeValue('Queue Kapp Slug'))}" scope="request" />


<%-- Define list of kapp attributes that should appear in the Display Options tab.
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
        <json:object>
            <json:property name="name" value="User Card Profile Attributes" />
            <json:property name="partial" value="checkboxInput.jsp" />
            <json:object name="data">
                <c:forEach var="o" items="${space.userProfileAttributeDefinitions}">
                    <json:property name="${o.name}" value="${o.name}" />
                </c:forEach>
            </json:object>
        </json:object>
    </json:array>
</c:set>

<%-- Display Options tab HTML --%>
<c:forEach var="attr" items="${json.parse(tabAttributes)}">
    <c:set var="definitionObject" value="${currentKapp.getKappAttributeDefinition(attr.name)}" scope="request" />
    <c:if test="${not empty definitionObject}">
        <c:set var="attributeObject" value="${currentKapp.getAttribute(attr.name)}" scope="request" />
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