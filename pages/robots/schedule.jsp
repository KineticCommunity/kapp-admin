<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<c:if test="${text.isNotBlank(param.robot)}">
    <c:catch var="caughtRobotError">
        <bundle:request method="get"
                        url="${bundle.apiPath}/submissions/${param.robot}?include=values"
                        var="robot"
                        scope="request" />
        <c:set var="currentRobot" value="${not empty robot ? json.parse(robot).submission : null}" scope="request" />
    </c:catch>
</c:if>
<c:if test="${text.isNotBlank(param.schedule)}">
    <c:catch var="caughtScheduleError">
        <bundle:request method="get"
                        url="${bundle.apiPath}/submissions/${param.schedule}?include=values"
                        var="schedule"
                        scope="request" />
        <c:set var="currentSchedule" value="${not empty schedule ? json.parse(schedule).submission : null}" scope="request" />
    </c:catch>
</c:if>

<!-- Show page content only if Robot exists. -->
<c:choose>
    <c:when test="${empty currentRobot}">
        <script>window.location.replace("${bundle.kappLocation}/${form.slug}?page=robots/robot&robot=${param.robot}");</script>
    </c:when>
    <c:otherwise>
    
        <bundle:layout page="${bundle.path}/layouts/layout.jsp">
            <!-- Sets title and imports js and css specific to this console. -->
            <bundle:variable name="head">
                <c:import url="${bundle.path}/partials/robots/head.jsp" charEncoding="UTF-8"/>
            </bundle:variable>
            
            <!-- BREADCRUMBS START HERE. Remove if not needed. ------------------------------------------->
            <bundle:variable name="breadcrumb">
                <li><a class="return-to-robots-console" href="${bundle.kappLocation}/${form.slug}">${form.name}</a></li>
                <li><a class="return-to-robot-definition" href="${bundle.kappLocation}/${form.slug}?page=robots/robot&robot=${currentRobot.id}#schedules">${currentRobot.values['Name']}</a></li>
                <li class="active">${empty currentSchedule ? 'New Schedule' : currentSchedule.values['Schedule Name']}</li>
            </bundle:variable>
            <!-- BREADCRUMBS END HERE. ------------------------------------------------------------------->
        
            <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
            
            <div class="page-header">
                <h2>
                    ${empty currentSchedule ? 'New Schedule' : currentSchedule.values['Schedule Name']}
                    <c:if test="${not empty currentRobot}"><small> Schedule for ${currentRobot.values['Name']} Robot</small></c:if>
                </h2>
            </div>
            
            <div class="row">
                <div class="col-xs-12">
                    
                    <c:if test="${not empty currentSchedule}"> 
                        <div class="robot-schedule-tab-navigation">
                            <ul class="nav nav-pills sub-nav" role="tablist">
                                <li role="presentation" class="active">
                                    <a href="#general" aria-controls="home" role="tab" data-toggle="tab">General</a>
                                </li>
                                <li>
                                    <a href="#executions" aria-controls="home" role="tab" data-toggle="tab">Executions</a>
                                </li>
                            </ul>
                        </div>
                    </c:if>
                    
                    <div class="tab-content robot-schedules-tab-content">
                    
                        <div role="tabpanel" class="tab-pane active" id="general">
                            <div class="robot-schedule-form-container embedded-form" data-robot-schedule-id="${currentSchedule.id}" 
                                 data-robot-submission-id="${currentRobot.id}" data-robot-id="${currentRobot.values['Robot ID']}">
                                <div class="alert alert-info">
                                    <span class="fa fa-spinner fa-spin"></span>
                                    Loading
                                </div>
                            </div>
                        </div>
                        
                        <c:if test="${not empty currentSchedule}"> 
                            <div role="tabpanel" class="tab-pane" id="executions">
                                <div class="page-header clearfix">
                                    <h4>
                                        Executions 
                                        <small> of ${currentSchedule.values['Schedule Name']} Schedule for ${currentRobot.values['Name']} Robot</small>
                                    </h4>
                                </div>
                               
                                <table style="width:100%" class="table table-hover table-striped dt-responsive nowrap" id="robot-schedule-executions-table"
                                       data-robot-id="${currentRobot.values['Robot ID']}" data-robot-submission-id="${currentRobot.id}" data-robot-schedule-id="${currentSchedule.id}">
                                    <tr>
                                        <td class="alert alert-info">
                                            <span class="fa fa-spinner fa-spin"></span>
                                            Loading
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </c:if> 
                    
                    </div>
                    
                </div>
            </div>
        
            <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
            
            <!-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -------------------------------->
            <bundle:variable name="aside">
                <h3>${form.name}</h3>
                 <h5>
                    ${empty currentSchedule ? 'New Schedule' : currentSchedule.values['Schedule Name']}
                    <c:if test="${not empty currentSchedule}"><small> Schedule</small></c:if>
                </h5>
                <hr class="border-color-white" />
                <c:choose>
                    <c:when test="${not empty currentRobot}">
                        <p>The <b>General</b> tab allows you to update the details of the schedule.</p>
                        <div class="p-l-2">
                            <p>To delete a schedule, click the <b>Delete Schedule</b> link.</p>
                        </div>
                        <hr class="border-color-white" />
                        <p>The <b>Executions</b> tab allows you to see the executions of this schedule.</p>
                        <div class="p-l-2">
                            <p>To view the details of an execution, click the view <b><span class="fa fa-search"></span></b> button.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                    </c:otherwise>
                </c:choose>
            </bundle:variable>
            <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
            
        </bundle:layout>
        
    </c:otherwise>
</c:choose>