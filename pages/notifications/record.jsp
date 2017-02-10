<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<!-- Show page content only if a Notification Type was selected exist. Otherwise redirect to Notifications home page. -->
<c:choose>
    <c:when test="${empty param.type && empty param.id}">
        <script>window.location.replace("${bundle.kappLocation}/${form.slug}");</script>
    </c:when>
    <c:otherwise>

        <bundle:layout page="${bundle.path}/layouts/layout.jsp">
            <!-- Sets title and imports js and css specific to this console. -->
            <bundle:variable name="head">
                <c:import url="${bundle.path}/partials/notifications/head.jsp" charEncoding="UTF-8"/>
            </bundle:variable>
            
            <!-- BREADCRUMBS START HERE. Remove if not needed. ------------------------------------------->
            <bundle:variable name="breadcrumb">
                <li><a class="return-to-notifcations" href="${bundle.kappLocation}/${form.slug}">${form.name}</a></li>
                <li class="active">${not empty param.id ? 'Edit' : empty param.clone ? 'New' : 'Clone'}</li>
            </bundle:variable>
            <!-- BREADCRUMBS END HERE. ------------------------------------------------------------------->
    
            <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
            
            <div class="page-header">
                <h3>${not empty param.id ? 'Edit ' : empty param.clone ? 'New ' : 'Clone '}Notification ${param.type} Record</h3>
            </div>
            
            <!-- SUBFORM GETS INSERTED HERE ---------------------------------------------------------------->
            <div class="row">
                <div class="col-xs-12">
                    <div class="notification-record-container embedded-form" 
                         data-record-id="${param.id}" data-clone-id="${param.clone}"
                         data-type="${param.type}">
                    </div>
                </div>
            </div>
            
            
            <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
    
            <!-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -------------------------------->
            <bundle:variable name="aside">
                <h3>${form.name}</h3>
                <p>${form.description}</p>
                <hr class="border-color-white" />
                <h4>Instructions</h4>
                <p>The <strong>Name</strong> field should be a unique value to identify this Template or Snippit</p>
                <p>The <strong>HTML Content</strong> field stores HTML that will be included in this notification</p>
                <p>The <strong>Text Content</strong> field should be non-HTML text and will be sent to users who can't view HTML emails.</p>
            </bundle:variable>
            <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
            
        </bundle:layout>
        
    </c:otherwise>
</c:choose>