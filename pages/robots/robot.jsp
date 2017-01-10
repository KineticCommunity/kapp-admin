<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<c:if test="${text.isNotBlank(param.robot)}">
    <c:catch var="caughtError">
        <bundle:request method="get"
                        url="${bundle.apiPath}/submissions/${param.robot}?include=values"
                        var="robot"
                        scope="request" />
        <c:set var="currentRobot" value="${not empty robot ? json.parse(robot).submission : null}" scope="request" />
        <bundle:request method="get"
                        url="${bundle.apiPath}/kapps/${kapp.slug}/forms/robot-schedules/submissions?limit=1&q=${text.escapeUrlSegment(text.join(['values[Robot ID] = ', '\"',currentRobot.values['Robot ID'] , '\"']))}"
                        var="schedules"
                        scope="request" />
        <c:set var="hasSchedules" value="${not empty schedules && json.parse(schedules).submissions.size() > 0 ? true : false}" scope="request" />        
    </c:catch>
</c:if>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <!-- Sets title and imports js and css specific to this console. -->
    <bundle:variable name="head">
        <c:import url="${bundle.path}/partials/robots/head.jsp" charEncoding="UTF-8"/>
    </bundle:variable>
    
    <!-- BREADCRUMBS START HERE. Remove if not needed. ------------------------------------------->
    <bundle:variable name="breadcrumb">
        <li><a class="return-to-robots-console" href="${bundle.kappLocation}/${form.slug}">${form.name}</a></li>
        <li class="active">${empty currentRobot ? 'New Robot' : currentRobot.values['Name']}</li>
    </bundle:variable>
    <!-- BREADCRUMBS END HERE. ------------------------------------------------------------------->

    <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
    
    <div class="page-header">
        <h3>
            ${empty currentRobot ? 'New Robot' : currentRobot.values['Name']}
            <c:if test="${not empty currentRobot}"><small> Robot</small></c:if>
        </h3>
    </div>
    
    <div class="row">
        <div class="col-xs-12">
            
            <c:if test="${not empty currentRobot}"> 
                <div class="robot-tab-navigation">
                    <ul class="nav nav-pills sub-nav" role="tablist">
                        <li role="presentation" class="active">
                            <a href="#general" aria-controls="home" role="tab" data-toggle="tab">General</a>
                        </li>
                        <li>
                            <a href="#schedules" aria-controls="home" role="tab" data-toggle="tab">Schedules</a>
                        </li>
                        <li>
                            <a href="#executions" aria-controls="home" role="tab" data-toggle="tab">Executions</a>
                        </li>
                    </ul>
                </div>
            </c:if>
            
            <div class="tab-content robots-tab-content">
            
                <div role="tabpanel" class="tab-pane active" id="general">
                    <div class="robot-form-container embedded-form" data-robot-submission-id="${currentRobot.id}" data-has-schedules="${hasSchedules}">
                        <div class="alert alert-info">
                            <span class="fa fa-spinner fa-spin"></span>
                            Loading
                        </div>
                    </div>
                </div>
                
                <c:if test="${not empty currentRobot}"> 
                    <div role="tabpanel" class="tab-pane" id="schedules">
                        <div class="page-header clearfix">
                            <h4>
                                Schedules 
                                <small> for ${currentRobot.values['Name']} Robot</small>
                                <div class="pull-right">
                                    <a class="btn btn-sm btn-tertiary" href="${bundle.kappLocation}/${form.slug}?page=robots/schedule&robot=${currentRobot.id}">
                                        <span class="fa fa-plus fa-fw"></span> Create Schedule
                                    </a>
                                </div>
                            </h4>
                        </div>
                       
                        <table style="width:100%" class="table table-hover table-striped dt-responsive nowrap" id="robot-schedules-table"
                               data-robot-id="${currentRobot.values['Robot ID']}" data-robot-submission-id="${currentRobot.id}">
                            <tr>
                                <td class="alert alert-info">
                                    <span class="fa fa-spinner fa-spin"></span>
                                    Loading
                                </td>
                            </tr>
                        </table>
                    </div>
                    
                    <div role="tabpanel" class="tab-pane" id="executions">
                        <div class="page-header clearfix">
                            <h4>
                                Executions 
                                <small> of ${currentRobot.values['Name']} Robot</small>
                            </h4>
                        </div>
                       
                        <table style="width:100%" class="table table-hover table-striped dt-responsive nowrap" id="robot-executions-table"
                               data-robot-id="${currentRobot.values['Robot ID']}" data-robot-submission-id="${currentRobot.id}">
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
        <h4>
            ${empty currentRobot ? 'New Robot' : currentRobot.values['Name']}
            <c:if test="${not empty currentRobot}"><small> Robot</small></c:if>
        </h4>
        <hr class="border-color-white" />
        <c:choose>
            <c:when test="${not empty currentRobot}">
                <p>The <b>General</b> tab allows you to update the details of the robot.</p>
                <div class="p-l-2">
                    <p>To delete a robot, click the <b>Delete Robot</b> link.</p>
                    <p><span class="fa fa-exclamation-circle"></span> You may not delete a robot that has schedules.</p>
                </div>
                <hr class="border-color-white" />
                <p>The <b>Schedules</b> tab allows you to manage the schedules for this robot.</p>
                <div class="p-l-2">
                    <p>To add a schedule, click the <b class="nowrap"><span class="fa fa-plus"></span> Create Schedule</b> button.</p>
                    <p>To manage a schedule or view its executions, click the edit <b><span class="fa fa-pencil"></span></b> button.</p>
                </div>
                <hr class="border-color-white" />
                <p>The <b>Executions</b> tab allows you to see the executions of the schedules for this robot.</p>
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