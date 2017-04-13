<%@page pageEncoding="UTF-8" contentType="application/json" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<c:set var="currentStore" value="${kapp.getForm('notification-data')}" scope="request" />
<c:set var="fields" value="${AdminHelper.getDatastoreColumns(currentStore, 'Datastore Configuration')}" scope="request" />
<c:set var="orderColumn" value="${0}" />
<c:set var="type" value="${param.type}" />
<c:set var="filters">
    <json:object>
        <c:forEach items="${paramValues}" var="p">
            <c:if test="${text.startsWith(p.key, 'values[')}">
                <json:property name="${p.key}" value="${p.value[0]}"/>
            </c:if>
        </c:forEach>
    </json:object>
</c:set>
<json:object>
  <json:array name="columns">
    <json:object>
      <json:property name="title" value=""/>
      <json:property name="defaultContent" value="&nbsp;"/>
      <json:property name="visible" value="${true}"/>
      <json:property name="class" value="control ignore-export all"/>
      <json:property name="orderable" value="${false}"/>
    </json:object>
    <c:forEach var="field" items="${fields}" varStatus="status">
      <c:choose>
        <c:when test="${fn:contains(field.title, 'Content')}">
          <c:if test="${not fn:contains(field.title, 'HTML')}">
            <json:object>
              <json:property name="title" value="${field.title}"/>
              <json:property name="data" value="${field.data}"/>
              <json:property name="renderType" value="notificationReplacement"/>
              <json:property name="class" value="none"/>
              <json:property name="visible" value="${field.visible}"/>
              <json:property name="searchable" value="${false}"/>
              <json:property name="orderable" value="${false}"/>
              <c:if test="${orderColumn eq 0 && field.visible eq true}">
                  <c:set var="orderColumn" value="${status.index+1}" />
              </c:if>
            </json:object>
          </c:if>
        </c:when>
        <c:when test="${field.title eq 'Subject' && type eq 'Snippet'}">
        </c:when>
        <c:when test="${field.title eq 'Subject' && type eq 'Template'}">
          <json:object>
            <json:property name="title" value="${field.title}"/>
            <json:property name="data" value="${field.data}"/>
            <json:property name="renderType" value="notificationReplacement"/>
            <json:property name="visible" value="${field.visible}"/>
            <json:property name="searchable" value="${field.searchable}"/>
            <json:property name="orderable" value="${field.orderable}"/>
            <c:if test="${orderColumn eq 0 && field.visible eq true}">
                <c:set var="orderColumn" value="${status.index+1}" />
            </c:if>
          </json:object>
        </c:when>
        <c:otherwise>
          <json:object>
            <json:property name="title" value="${field.title}"/>
            <json:property name="data" value="${field.data}"/>
            <json:property name="renderType" value="${field.renderType}"/>
            <json:property name="visible" value="${field.visible}"/>
            <json:property name="searchable" value="${field.searchable}"/>
            <json:property name="orderable" value="${field.orderable}"/>
            <c:if test="${orderColumn eq 0 && field.visible eq true}">
                <c:set var="orderColumn" value="${status.index+1}" />
            </c:if>
          </json:object>
        </c:otherwise>
      </c:choose>
    </c:forEach>
    <json:object>
      <json:property name="title" value="ID"/>
      <json:property name="data" value="ID"/>
      <json:property name="visible" value="${false}"/>
    </json:object>
    <json:object>
      <json:property name="title" value=""/>
      <json:property name="data" value=""/>
      <json:property name="visible" value="${true}"/>
      <json:property name="renderType" value="actionButtons"/>
      <json:property name="class" value="actions actions-lg ignore-export all"/>
      <json:property name="orderable" value="${false}"/>
      <json:property name="defaultContent" value="<div class=\"btn-group datastore-btns\"><button class=\"btn btn-xs btn-default edit\" title=\"Edit\"><span class=\"fa fa-pencil fa-fw\"></span></button><button class=\"btn btn-xs btn-success clone\" title=\"Clone\"><span class=\"fa fa-clone fa-fw\"></span></button><button class=\"btn btn-xs btn-danger delete\" title=\"Delete\"><span class=\"fa fa-times fa-fw\"></span></button></div> "/>
    </json:object>
  </json:array>
  <json:array name="data" var="formSubmission" items="${AdminHelper.getDatastoreRecords(currentStore, json.parse(filters), param.pageToken)}">
    <json:object>
      <c:forEach var="field" items="${fields}">
        <json:property name="${field.data}" value="${formSubmission.values[field.data]}"/>
      </c:forEach>
      <json:property name="ID" value="${formSubmission.id}"/>
    </json:object>
  </json:array>
  <json:array name="order">
    <json:array>
      <json:property value="${orderColumn}"/>
      <json:property value="asc"/>
    </json:array>
  </json:array>
</json:object>