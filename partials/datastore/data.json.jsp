<%@page pageEncoding="UTF-8" contentType="application/json" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<c:set var="currentStore" value="${kapp.getForm(param.store)}" scope="request" />
<c:set var="fields" value="${AdminHelper.getDatastoreColumns(currentStore, 'Datastore Configuration')}" scope="request" />
<c:set var="filters">
    <json:object>
        <c:forEach items="${paramValues}" var="p">
            <c:if test="${text.startsWith(p.key, 'values[')}">
                <json:property name="${p.key}" value="${p.value[0]}"/>
            </c:if>
        </c:forEach>
    </json:object>
</c:set>
<c:set var="records" value="${AdminHelper.getDatastoreRecords(currentStore, json.parse(filters), param.pageToken)}" scope="request" />
<json:object>
  <json:array name="data" var="record" items="${records}">
    <json:object>
      <c:forEach var="field" items="${fields}">
        <json:property name="${field.data}" value="${record.values[field.data]}"/>
      </c:forEach>
      <json:property name="ID" value="${record.id}"/>
    </json:object>
  </json:array>
  <json:property name="_nextPageToken" value="${records.getNextPageToken()}" />
</json:object>