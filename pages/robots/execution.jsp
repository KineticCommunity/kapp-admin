<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<c:if test="${text.isNotBlank(param.execution)}">
    <c:catch var="caughtExecutionError">
        <bundle:request method="get"
                        url="${bundle.apiPath}/submissions/${param.execution}?include=values"
                        var="execution"
                        scope="request" />
        <c:set var="currentExecution" value="${not empty execution ? json.parse(execution).submission : null}" scope="request" />
        <bundle:request method="get"
                        url="${bundle.apiPath}/submissions/${currentExecution.values['Schedule ID']}?include=values"
                        var="schedule"
                        scope="request" />
        <c:set var="currentSchedule" value="${not empty schedule ? json.parse(schedule).submission : null}" scope="request" />
    </c:catch>
</c:if>
<c:if test="${text.isNotBlank(param.robot)}">
    <c:catch var="caughtRobotError">
        <bundle:request method="get"
                        url="${bundle.apiPath}/submissions/${param.robot}?include=values"
                        var="robot"
                        scope="request" />
        <c:set var="currentRobot" value="${not empty robot ? json.parse(robot).submission : null}" scope="request" />
    </c:catch>
</c:if>

<c:choose>
    <c:when test="${empty currentRobot}">
        <c:set var="error" value="${i18n.translate('The selected robot could not be found.')}" />
    </c:when>
    <c:when test="${empty currentExecution}">
        <c:set var="error" value="${i18n.translate('The selected execution could not be found.')}" />
    </c:when>
</c:choose>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <!-- Sets title and imports js and css specific to this console. -->
    <bundle:variable name="head">
        <c:import url="${bundle.path}/partials/robots/head.jsp" charEncoding="UTF-8"/>
    </bundle:variable>
    
    <!-- BREADCRUMBS START HERE. Remove if not needed. ------------------------------------------->
    <bundle:variable name="breadcrumb">
        <li><a href="${bundle.kappLocation}/${form.slug}">${form.name}</a></li>
        <c:choose>
            <c:when test="${not empty currentRobot}">
                <li><a href="${bundle.kappLocation}/${form.slug}?page=robots/robot&robot=${currentRobot.id}#executions">${currentRobot.values['Name']}</a></li>
                <c:choose>
                    <c:when test="${not empty currentExecution}">
                        <c:if test="${not empty currentSchedule}">
                            <li><a href="${bundle.kappLocation}/${form.slug}?page=robots/schedule&schedule=${currentSchedule.id}&robot=${currentRobot.id}#executions">${currentSchedule.values['Schedule Name']}</a></li>
                        </c:if>
                        <li class="active">Execution Details</li>
                    </c:when>
                    <c:otherwise>
                        <li class="active">Execution Not Found</li>
                    </c:otherwise>
                </c:choose>
            </c:when>
            <c:otherwise>
                <li class="active">Robot Not Found</li>
            </c:otherwise>
        </c:choose>
    </bundle:variable>
    <!-- BREADCRUMBS END HERE. ------------------------------------------------------------------->

    <c:choose>
        <c:when test="${empty error}">
        
            <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
            
            <div class="page-header">
                <h2>
                    Execution Details
                    <small>
                        of ${currentSchedule.values['Schedule Name']} Schedule 
                        for ${currentRobot.values['Name']} Robot
                    </small>
                </h2>
            </div>
            
            <div class="row">
                <div class="col-xs-12">
                    
                    <div class="robot-execution-form-container embedded-form" data-robot-execution-id="${currentExecution.id}">
                        <div class="alert alert-info">
                            <span class="fa fa-spinner fa-spin"></span>
                            Loading
                        </div>
                    </div>
                    
                </div>
            </div>
        
            <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
            
            <!-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -------------------------------->
            <bundle:variable name="aside">
            </bundle:variable>
            <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
            
        </c:when>
        <c:otherwise>
            <c:import url="${bundle.path}/partials/error.jsp" charEncoding="UTF-8">
                <c:param name="message" value="${error}"/>
            </c:import>
        </c:otherwise>
    </c:choose>
    
</bundle:layout>