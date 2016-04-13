<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <!-- Sets title and imports js and css specific to this console. -->
    <bundle:variable name="head">
        <title>Admin Console<c:if test="${not empty form}"> | ${form.name}</c:if></title>
        <c:import url="${bundle.path}/partials/${not empty form ? form.slug : ''}/head.jsp" charEncoding="UTF-8"/>
    </bundle:variable>

    <c:set var="currentKapp" value="${space.getKapp(param.kapp)}" scope="request" />

    <!-- Show page content only if Kapp exists. Otherwise show error. -->
    <c:choose>
        <c:when test="${empty currentKapp}">
            <c:redirect url="${bundle.kappPath}"/>
        </c:when>
        <c:otherwise>
            
            <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
            
            <div class="page-header">
                <h3>${form.name}</h3>
            </div>
        
            <div class="row">
                <div class="col-xs-12">
                    <div class="content-tabs">
                        <ul class="nav nav-pills sub-nav">
                            <li class="active">
                                <a href="javascript:void(0);">Tab 1</a>
                            </li>
                            <li>
                                <a href="javascript:void(0);">Tab 2</a>
                            </li>
                            <li>
                                <a href="javascript:void(0);">Tab 3</a>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
        
            <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
    
            <!-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -------------------------------->
            <bundle:variable name="aside">
                <h3>TITLE</h3>
                <p>
                    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor 
                    incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud 
                    exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute 
                    irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla 
                    pariatur.
                </p>
            </bundle:variable>
            <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
            
        </c:otherwise>
    </c:choose>
</bundle:layout>