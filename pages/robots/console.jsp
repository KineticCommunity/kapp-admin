<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<%@include file="../../bundle/router.jspf" %>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <!-- Sets title and imports js and css specific to this console. -->
    <bundle:variable name="head">
        <c:import url="${bundle.path}/partials/robots/head.jsp" charEncoding="UTF-8"/>
    </bundle:variable>
    
    <!-- BREADCRUMBS START HERE. Remove if not needed. ------------------------------------------->
    <bundle:variable name="breadcrumb">
        <li class="active">${form.name}</li>
    </bundle:variable>
    <!-- BREADCRUMBS END HERE. ------------------------------------------------------------------->

    <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
    
    <div class="page-header">
        <h2>
            ${text.escape(form.name)}
            <div class="pull-right robots-table-buttons">
                <a class="btn btn-tertiary" href="${bundle.kappLocation}/${form.slug}?page=robots/robot">
                    <span class="fa fa-plus fa-fw"></span> Create Robot
                </a>
            </div>
        </h2>
    </div>
    
    <div class="row">
        <div class="col-xs-12">
            
            <table style="width:100%" class="table table-hover dt-responsive nowrap" id="robots-table">
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
        <p>${form.description}</p>
        <hr class="border-color-white" />
        <p>To create a new robot, click the <b class="nowrap"><span class="fa fa-plus"></span> Create Robot</b> button.</p>
        <p>To manage a robot and its schedules or view its executions, click the edit <b><span class="fa fa-pencil"></span></b> button.</p>
    </bundle:variable>
    <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
    
</bundle:layout>