<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../bundle/initialization.jspf" %>

<nav class="navbar navbar-default" id="bundle-subheader">
    <div class="container">
        <div class="row">
            <div class="col-sm-10 breadcrumbs">
                <ol class="breadcrumb">
                    <li>
                        <a href="${bundle.kappLocation}">
                            <span class="fa ${kapp.getAttributeValue('Icon')}"></span>
                            <span>${i18n.translate(kapp.name)}</span>
                        </a>
                    </li>
                    <bundle:yield name="breadcrumb"/>
                </ol>
            </div>
            <div class="col-sm-2 text-right additional-menu hidden-sm hidden-md hidden-lg">
                <ul class="unstyled">
                    <c:set var="aside"><bundle:yield name="aside"/></c:set>
                    <c:if test="${not empty aside}">
                        <li><a href="javascript:bundle.admin.openAsidePopup();"><span class="fa fa-info-circle fa-lg fa-fw"></span></a></li>
                    </c:if>
                </ul>
            </div>
        </div>
    </div>
</nav>