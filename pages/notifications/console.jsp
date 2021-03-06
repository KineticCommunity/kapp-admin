<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<%@include file="../../bundle/router.jspf" %>

<!-- Set variable to hold the notification type (Template or Snippet). -->
<c:set var="notificationType" value="${not empty param.type? param.type : 'Template'}s"/>
<c:choose>
    <c:when test="${notificationType eq 'Snippets'}">
         <c:redirect url="${bundle.kappPath}/${form.slug}?page=notifications/snippets&type=Snippet"/>
    </c:when>
    <c:otherwise>
        <bundle:layout page="${bundle.path}/layouts/layout.jsp">
            <!-- Sets title and imports js and css specific to this console. -->
            <bundle:variable name="head">
                <c:import url="${bundle.path}/partials/notifications/head.jsp" charEncoding="UTF-8"/>
                <script>
                    bundle.notifications.type = "Template";
                </script>
            </bundle:variable>

            <!-- BREADCRUMBS START HERE. Remove if not needed. ------------------------------------------->
            <bundle:variable name="breadcrumb">
                <li class="active">${form.name}</li>
            </bundle:variable>
            <!-- BREADCRUMBS END HERE. ------------------------------------------------------------------->

            <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->

            <div class="page-header">
                <h2>Notification <small> ${notificationType}</small>
                    <div class="pull-right notification-table-buttons">
                        <a class="btn btn-tertiary" href="${bundle.kappLocation}/${form.slug}?page=notifications/record&type=Template">
                            <span class="fa fa-plus fa-fw"></span> Add Template
                        </a>
                        <input class="hide" accept=".csv" data-type="Template" id="notification-import" type="file">
                    </div>
                </h2>
            </div>
    
            <div>
                <ul class="nav nav-tabs h4 stacked-xs" role="tablist" id="form-configuration-tabs">
                    <li role="presentation" class="active"><a href="javascript:void(0);">Templates</a></li>
                    <li role="presentation"><a href="${bundle.kappLocation}/${form.slug}?page=notifications/snippets&type=Snippet">Snippets</a></li>
                </ul>
                <div class="m-t-2">
                    <table id="table-notifications" style="width:100%" class="table table-hover dt-responsive nowrap" 
                           data-console-slug="${form.slug}" 
                           data-kapp-slug="${kapp.slug}" 
                           data-datastore-slug="notification-data" 
                           id="table-notifications" 
                           data-type="Template" 
                           data-query="values[Type]=Template">
                        <tr>
                            <td class="alert alert-info">
                                <span class="fa fa-spinner fa-spin"></span>
                                Loading
                            </td>
                        </tr>
                    </table>
                </div>
            </div>

            <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
            
            <!-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -------------------------------->
            <bundle:variable name="aside">
                <h3>${form.name}</h3>
                <h5>${notificationType}</h5>
                <p>${form.description}</p>
                <hr class="border-color-white" />
                <p>To add a new notification, click the <b class="nowrap"><span class="fa fa-plus"></span> Add Template</b> button.</p>
                <p>To edit a notification, click the edit <b><span class="fa fa-pencil"></span></b> button.</p>
                <p>To clone a notification, click the clone <b><span class="fa fa-clone"></span></b> button.</p>
                <p>To delete a record, click the delete <b><span class="fa fa-times"></span></b> button.</p>
                <p>To export the notification to a CSV file, click the <b>Export CSV</b> button.</p>
                <p>To import notification from a CSV file, click the <b>Import CSV</b> button and select the file you want to import.</p>
                <div class="p-l-2">
                    <p>
                        The CSV file you import must have columns with headings corresponding to existing field names. 
                        It may also have an <i>"ID"</i> column, used to update existing records.
                    </p>
                </div>
                <p><b>
                    <span class="fa fa-exclamation-circle"></span> Importing notification records does not perform the form validations, 
                    which may allow for invalid data to be saved. Please be careful so you do not destroy your data. 
                </b></p>
            </bundle:variable>
            <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
        </bundle:layout>
    </c:otherwise>
</c:choose>