<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<c:set var="currentKapp" value="${space.getKapp(param.kapp)}" scope="request" />
<c:set var="currentRobot" value="${kapp.getForm(param.robot)}" scope="request" />

<!-- Show page content only if Kapp & Robot exist. Otherwise redirect to valid page. -->
<c:choose>
    <c:when test="${empty currentKapp}">
        <script>window.location.replace("${bundle.kappLocation}");</script>
    </c:when>
    <c:when test="${empty currentRobot}">
        <script>window.location.replace("${bundle.kappLocation}/${form.slug}?kapp=${currentKapp.slug}");</script>
    </c:when>
    <c:otherwise>

        <bundle:layout page="${bundle.path}/layouts/layout.jsp">
            <!-- Sets title and imports js and css specific to this console. -->
            <bundle:variable name="head">
                <c:import url="${bundle.path}/partials/robot/head.jsp" charEncoding="UTF-8"/>
            </bundle:variable>
    
            <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
            
            <ol class="breadcrumb">
                <li><a href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}">${form.name}</a></li>
                <li><a href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=robot/robot&robot=${currentRobot.slug}" class="return-to-robot">${currentRobot.name}</a></li>
                <li class="active ng-binding">${not empty param.id ? 'Edit' : empty param.clone ? 'New' : 'Clone'}</li>
            </ol>
            
            <div class="page-header">
                <h3>${not empty param.id ? 'Edit ' : empty param.clone ? 'New ' : 'Clone '}${currentRobot.name} Record</h3>
            </div>
            
            <div class="row">
                <div class="col-xs-12">
<%-- TODO restrict duplicates <c:set var="uniqueFields" value="${AdminHelper.getUniqueFields(currentRobot)}"/>  data-unique-fields="${uniqueFields}"--%>
                    <div class="robot-record-container" data-robot-slug="${currentRobot.slug}"
                            data-record-id="${param.id}" data-clone-id="${param.clone}"></div>
                </div>
            </div>
            
            
            <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
    
            <!-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -------------------------------->
            <bundle:variable name="aside">
                <h3>${currentRobot.name}</h3>
                <p>
                    ${currentRobot.description}
                </p>
            </bundle:variable>
            <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
            
        </bundle:layout>
        
    </c:otherwise>
</c:choose>