<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<%@include file="../../bundle/router.jspf" %>
<c:set var="currentKapp" value="${space.getKapp(param.kapp)}" scope="request" />

<!-- Show page content only if Kapp exists. Otherwise redirect to valid page. -->
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
                        
            <div class="page-header">
                <h3>
                    ${form.name}
                    <div class="pull-right">
                        <a class="btn btn-sm btn-primary" href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=robot/config">
                            <span class="fa fa-plus fa-fw"></span> Create Robot
                        </a>
                    </div>
                </h3>
            </div>
        
            <div class="row">
                <div class="col-xs-12">
                    <c:choose>
                        <c:when test="${empty kapp.getFormsByType('Robot')}">
                            <div class="table no-data text-center">
                                <h4>There are no robots to display.</h4>
                                <a href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=robot/config">
                                    <span class="fa fa-plus fa-fw"></span> Create Robot
                                </a>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <table class="table table-hover"> 
                                <thead>
                                    <tr>
                                        <th>Name</th>
                                        <th>Description</th>
                                        <th></th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach items="${kapp.getFormsByType('Robot')}" var="robot">
                                        <tr>
                                            <td><a href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=robot/robot&robot=${robot.slug}">${robot.name}</a></td>
                                            <td>${robot.description}</td>
                                            <td>
                                                <div class="btn-group pull-right">
                                                    <a class="btn btn-xs btn-default" href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=robot/config&robot=${robot.slug}">
                                                        <span class="fa fa-cog fa-fw"></span>
                                                    </a>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        
            <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
            
            <!-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -------------------------------->
            <bundle:variable name="aside">
                <h3>Kinetic Robot</h3>
                <p>
                    The listed robots have been configured in the Robot Console. 
                </p>
                <p>
                    To add a new robot, click the <b>Create Robot</b> button.
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