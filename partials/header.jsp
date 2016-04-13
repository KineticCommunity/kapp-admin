<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../bundle/initialization.jspf" %>

<nav class="navbar navbar-default" role="navigation">
    
    <c:set var="currentKapp" value="${space.getKapp(param.kapp)}" scope="request" />
    
    <div class="kapp-selector nav-title">
        <div class="kapp-current dropdown">
            <a href="javascript:void(0);" data-toggle="dropdown" class="dropdown-toggle" aria-haspopup="true" aria-expanded="false">
                <img src="${bundle.location}/images/ProductName-Request.png" height="40px">
                <span class="fa fa-caret-down"></span>
            </a>
            <ul class="kapp-list dropdown-menu"> 
                <li><a href="${bundle.kappLocation}"><span class="fa fa-home"></span> Home</a></li>
                <li class="divider "></li>
                <c:forEach var="consoleKapp" items="${AdminHelper.getActiveKapps()}">
                    <li><a href="${bundle.kappLocation}?kapp=${consoleKapp.slug}">${consoleKapp.name}</a></li>
                </c:forEach>
            </ul> 
        </div>
    </div>
    
    <h2 class="kapp-title">
        Admin Console <if test="${not empty currentKapp}"><a href="${bundle.spaceLocation}/${currentKapp.slug}" target="_blank"><small> ${currentKapp.name}</small></a></if>
    </h2>
    
    <ul class="nav navbar-nav navbar-right">
        <li class="dropdown">
            <c:choose>
                <c:when test="${identity.anonymous}">
                    <a href="${bundle.spaceLocation}/app/login">
                        <div class="account">
                            <span class="fa fa-sign-in fa-fw"></span>
                            Login
                        </div>
                    </a>
                </c:when>
                <c:otherwise>
                    <a href="javascript:void(0);" class="dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                        <div class="account">
                            <span class="fa fa-user fa-fw"></span>
                            <span>${text.escape(identity.displayName)}</span>
                            <span class="fa fa-caret-down"></span>
                        </div>
                    </a>
                </c:otherwise>
            </c:choose>
            <ul class="dropdown-menu">
                <c:if test="${not identity.anonymous}">
                    <li><a href="${bundle.spaceLocation}/?page=profile"><i class="fa fa-pencil fa-fw"></i> Edit Profile</a></li>
                    <li class="divider"></li>
                    <li><a href="${bundle.spaceLocation}/app/"><i class="fa fa-dashboard fa-fw"></i> Management Console</a></li>
                    <li class="divider"></li>
                    <li><a href="${bundle.spaceLocation}/app/logout"><i class="fa fa-sign-out fa-fw"></i> Logout</a></li>
                </c:if>
            </ul>
        </li>
        <li class="dropdown">
            <a href="javascript:void(0);" data-toggle="dropdown" class="dropdown-toggle"  aria-haspopup="true" aria-expanded="false">
                Help
                <span class="fa fa-caret-down fa-fw"></span>
            </a>
            <ul class="dropdown-menu">
                <li class="dropdown-header">Kinetic Community</li>
                <li><a href="http://community.kineticdata.com/Internal/Documentation_-_Kinetic_Core/40_Setup_Console/Kapp_Setup/10_Kapp_Setup_Details" target="_blank">Kapp Setup Help</a></li>
                <li class="divider"></li>
                <li><a href="javascript:void(0);" target="_blank">About this Kapp</a></li>
            </ul>
        </li>
    </ul>
</nav>
