<%@page pageEncoding="UTF-8" contentType="application/json" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<c:set var="currentStore" value="${kapp.getForm(param.store)}" scope="request" />
<c:set var="fields" value="${AdminHelper.getDatastoreColumns(currentStore)}" scope="request" />
<json:object>
  <json:array name="columns">
    <c:forEach var="field" items="${fields}">
      <json:object>
        <json:property name="title" value="${field.title}"/>
        <json:property name="data" value="${field.data}"/>
        <json:property name="visible" value="${field.visible}"/>
        <json:property name="searchable" value="${field.searchable}"/>
        <json:property name="orderable" value="${field.orderable}"/>
      </json:object>
    </c:forEach>
    <json:object>
      <json:property name="title" value="Datastore Record ID"/>
      <json:property name="data" value="ID"/>
      <json:property name="visible" value="false"/>
    </json:object>
    <json:object>
      <json:property name="title" value=""/>
      <json:property name="data" value=""/>
      <json:property name="visible" value="true"/>
      <json:property name="class" value="all"/>
      <json:property name="orderable" value="false"/>
      <json:property name="defaultContent" value="<div class=\"btn-group datastore-btns\"><button class=\"btn btn-xs btn-default edit\" title=\"Edit\"><span class=\"fa fa-pencil fa-fw\"></span></button><button class=\"btn btn-xs btn-success clone\" title=\"Clone\"><span class=\"fa fa-clone fa-fw\"></span></button><button class=\"btn btn-xs btn-danger delete\" title=\"Delete\"><span class=\"fa fa-times fa-fw\"></span></button></div> "/>
    </json:object>
  </json:array>
  <json:array name="data" var="formSubmission" items="${AdminHelper.getDatastoreRecords(currentStore)}">
    <json:object>
      <c:forEach var="field" items="${fields}">
        <json:property name="${field.data}" value="${formSubmission.values[field.data]}"/>
      </c:forEach>
      <json:property name="ID" value="${formSubmission.id}"/>
    </json:object>
  </json:array>
</json:object>