<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<c:set var="currentKapp" value="${space.getKapp(param.kapp)}" scope="request" />
<c:set var="currentRobot" value="${kapp.getForm(param.robot)}" scope="request" />

<!-- Show page content only if Kapp & Robot exist. Otherwise redirect to valid page. -->
<c:choose>
    <c:when test="${empty currentKapp}">
        <script>window.location.replace("${bundle.kappLocation}");</script>
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
                <li class="active ng-binding">${empty currentRobot ? 'New Robot' : currentRobot.name}</li>
            </ol>
            
            <div class="page-header">
                <h3>
                    ${not empty currentRobot ? currentRobot.name : 'New Robot'}  
                    <c:if test="${not empty currentRobot}">
                        <small> Configuration</small>
                        <div class="pull-right">
                            <a class="btn btn-sm btn-default" href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=robot/robot&robot=${currentRobot.slug}">
                                <span class="fa fa-database fa-fw"></span>Records
                            </a>
                            <a class="btn btn-sm btn-primary" href="${bundle.spaceLocation}/app/#/${kapp.slug}/author/form/${currentRobot.slug}/builder" target="_blank">
                                <span class="fa fa-mouse-pointer fa-fw"></span>Builder
                            </a>
                            <a class="btn btn-sm btn-primary" href="javascript:location.reload(true);">
                                <span class="fa fa-refresh fa-fw"></span>
                            </a>
                        </div>
                    </c:if>
                </h3>
            </div>
            
            <form id="${empty param.robot ? 'create-robot-form' : 'update-robot-form'}" action="javascript:void(0);">
                <fieldset>
                    <div class="row">
                        <div class="col-xs-6">
                            <div class="form-group">
                                <label for="robot-name" class="control-label">
                                    <abbr title="Required">*</abbr> Name
                                </label>
                                <input id="robot-name" placeholder="Robot Title" name="name" class="form-control" value="${currentRobot.name}">
                            </div> 
                        </div>
                        <div class="col-xs-6">
                            <div class="form-group">
                                <label for="robot-slug" class="control-label">
                                    <abbr title="Required">*</abbr> Slug
                                </label>
                                <input id="robot-slug" placeholder="Robot Slug" name="slug" class="form-control" value="${currentRobot.slug}">
                            </div> 
                        </div>
                    </div> 
                    <div class="row">
                        <div class="col-xs-12">
                            <div class="form-group">
                                <label for="robot-description" class="control-label text optional">Description</label>
                                <small> (optional)</small>
                                <textarea id="robot-description" cols="40" rows="4" maxlength="4000" name="description" placeholder="Description of Robot" class="form-control">${currentRobot.description}</textarea>
                            </div>
                        </div>
                    </div>
                </fieldset>
                
                <c:if test="${not empty currentRobot}">
                    <label for="column-table" class="text">Display Table Options</label> <small>(drag to order)</small>
                    <table class="table table-hover" id="column-table"> 
                        <thead>
                            <tr>
                                <th style="width:55%;">Field Name</th>
                                <th style="width:15%;">Visible</th>
                                <th style="width:15%;">Searchable</th>
                                <th style="width:15%;">Sortable</th>
<!--                                 <th style="width:15%;">Unique</th> -->
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="column" items="${AdminHelper.getDatastoreColumns(currentRobot, 'Robot Configuration')}">
                                <tr>
                                    <td class="column-name">${column.data}</td>
                                    <td class="column-visible"><input type="checkbox" ${column.visible ? 'checked' : ''}/></td>
                                    <td class="column-searchable"><input type="checkbox" ${column.searchable ? 'checked' : ''}/></td>
                                    <td class="column-orderable"><input type="checkbox" ${column.orderable ? 'checked' : ''}/></td>
<%--                                     <td class="column-unique"><input type="checkbox" ${column.unique ? 'checked' : ''}/></td> --%>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:if>
                
                <div class="row">
                    <div class="col-xs-12">
                        <div class="form-buttons pull-right">
                            <button type="button" class="btn btn-success" id="${empty param.robot ? 'create-robot' : 'update-robot'}" data-robot-slug="${currentRobot.slug}" data-console-slug="${form.slug}">
                                <span class="fa fa-check fa-fw"></span>${empty param.robot ? 'Create' : 'Save'}
                            </button>
                            <a class="btn btn-link" href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}">Cancel</a>
                        </div>
                    </div>
                </div>
            </form>
        
            <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
    
            <!-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -------------------------------->
            <bundle:variable name="aside">
                <h3>${not empty currentRobot ? currentRobot.name : 'New Robot'}</h3>
                <p>
                    ${currentRobot.description}
                </p>
                <hr />
                <p>
                    <span class="fa fa-exclamation-circle"></span> Robot forms can not contain more than 1 page.
                </p>
            </bundle:variable>
            <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
            
        </bundle:layout>
        
    </c:otherwise>
</c:choose>