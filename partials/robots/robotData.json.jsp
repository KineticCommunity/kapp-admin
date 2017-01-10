<%@page pageEncoding="UTF-8" contentType="application/json" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<c:set var="fields" value="${AdminHelper.getRobotColumns(kapp.getForm(param.data))}" scope="request" />
<c:choose>
    <c:when test="${text.equals(param.data, 'robot-definitions')}">
        <c:set var="data" value="${AdminHelper.getRobotDefinitions()}" scope="request" />
    </c:when>
    <c:when test="${text.equals(param.data, 'robot-schedules')}">
        <c:set var="data" value="${AdminHelper.getRobotSchedules(param.robotId)}" scope="request" />
    </c:when>
    <c:when test="${text.equals(param.data, 'robot-executions')}">
        <c:set var="data" value="${AdminHelper.getRobotExecutions(param.pageSize, param.pageToken, param.robotId, param.scheduleId)}" scope="request" />
    </c:when>
    <c:otherwise>
        <c:set var="data" value="${[]}" scope="request" />
    </c:otherwise>
</c:choose>
<c:set var="orderColumn" value="${0}" />
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
      <json:object>
        <json:property name="title" value="${field.title}"/>
        <json:property name="data" value="${field.data}"/>
        <json:property name="renderType" value="${field.renderType}"/>
        <json:property name="visible" value="${field.visible}"/>
        <json:property name="searchable" value="${field.searchable}"/>
        <json:property name="orderable" value="${field.orderable}"/>
        <c:choose>
            <c:when test="${not empty field.defaultOrder && empty orderDirection}">
                <c:set var="orderColumn" value="${status.index+1}" />
                <c:set var="orderDirection" value="${field.defaultOrder}"/>            
            </c:when>
            <c:when test="${orderColumn eq 0 && field.visible eq true}">
                <c:set var="orderColumn" value="${status.index+1}" />
            </c:when>
        </c:choose>
      </json:object>
    </c:forEach>
    <json:object>
      <json:property name="title" value="Submission ID"/>
      <json:property name="data" value="ID"/>
      <json:property name="visible" value="${false}"/>
    </json:object>
    <json:object>
      <json:property name="renderType" value="actions"/>
      <json:property name="visible" value="${true}"/>
      <json:property name="class" value="actions-xs ignore-export all"/>
      <json:property name="orderable" value="${false}"/>
      <json:property name="searchable" value="${false}"/>
      <json:property name="defaultContent" value=""/>
    </json:object>
  </json:array>
  <json:array name="data">
    <c:forEach var="formSubmission" items="${data}">
      <json:object>
        <c:forEach var="field" items="${fields}">
          <json:property name="${field.data}" value="${formSubmission.values[field.data]}"/>
        </c:forEach>
        <json:property name="ID" value="${formSubmission.id}"/>
      </json:object>
    </c:forEach>
  </json:array>
  <json:array name="order">
    <json:array>
      <json:property value="${orderColumn}"/>
      <json:property value="${not empty orderDirection ? orderDirection : 'asc'}"/>
    </json:array>
  </json:array>
  <json:property name="_nextPageToken" value="${data.getNextPageToken()}"/>
</json:object>