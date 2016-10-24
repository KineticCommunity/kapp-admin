<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../bundle/initialization.jspf" %>

<nav class="navbar navbar-default" id="bundle-subheader">
    <div class="container">
        <div class="row">
            <div class="col-sm-10 breadcrumbs">
                <ol class="breadcrumb">
                    <li>
                        <a href="${bundle.kappLocation}">
                            <h4>
                                <span class="fa ${kapp.getAttributeValue('Icon')}"></span>
                                <span>${kapp.name}</span>
                            </h4>
                        </a>
                    </li>
                    <bundle:yield name="breadcrumb"/>
                </ol>
            </div>
            <div class="col-sm-2 text-right additional-menu">
                <ul class="unstyled">
                    <li>
                        <a href="javascript:void(0);" data-toggle="dropdown" class="dropdown-toggle"  aria-haspopup="true" aria-expanded="false">
                            Help
                            <span class="fa fa-caret-down fa-fw"></span>
                        </a>
                        <ul class="dropdown-menu dropdown-menu-right">
                            <c:if test="${not empty form}">
                                <c:set var="helpLinks" value="${AdminHelper.getHelpLinks(form)}" />
                                <c:forEach var="link" items="${helpLinks}">
                                    <li><a href="${link.href}" target="_blank">${link.name}</a></li>
                                </c:forEach>
                                <li class="divider ${empty helpLinks ? 'hide' : ''}"></li>
                            </c:if>
                            <li><a href="https://community.kineticdata.com/10_Kinetic_Request/Kinetic_Request_Core_Edition/Resources/Kapp-Admin" target="_blank">About Admin Console</a></li>
                        </ul>
                    </li>
                </ul>
            </div>
        </div>
    </div>
</nav>