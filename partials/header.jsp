<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../bundle/initialization.jspf" %>

<bundle:stylepack>
    <bundle:style src="${headerLocation}/css/header.css" />
</bundle:stylepack>
<bundle:scriptpack>
    <bundle:script src="${headerLocation}/js/header.js" />
</bundle:scriptpack>

<c:set var="adminKapp" value="${space.getKapp(space.getAttributeValue('Admin Kapp Slug'))}" />
<c:set var="brand"><bundle:yield name="brand"/></c:set>

<nav class="navbar navbar-default" id="bundle-header">
    <div class="container">
        <div class="navbar-header">

            <%-- Mobile Menu Button --%>
            <button class="navbar-toggle collapsed dropdown" data-toggle="collapse"
                    data-target="#bundle-header-drawer" aria-expanded="false">
                <span class="fa fa-bars fa-lg fa-fw"></span>
            </button>

            <%-- Web Menu Button --%>
            <ul class="nav navbar-nav hidden-xs">
                <%-- Dropdown Menu Links --%>
                <li class="dropdown">
                    <a id="linkMenu" href="javascript:void(0);" class="dropdown-toggle hidden-xs" data-toggle="dropdown"
                       title="${i18n.translate('Applications')}" aria-haspopup="true" aria-expanded="false">
                        <span class="hidden-xs fa fa-bars fa-lg"></span>
                    </a>
                    <ul class="dropdown-menu" aria-labelledby="linkMenu">
                        <%-- Navigation links defined in navigation.jsp --%>
                        <c:import url="${headerPath}/partials/navigation.jsp" charEncoding="UTF-8" />
                    </ul>
                </li>
            </ul>

            <%-- Home Link(s) --%>
            <div class="navbar-brand">
                <a class="space-home-link" href="${bundle.spaceLocation}">
                    <span class="hidden-sm hidden-md hidden-lg fa fa-home"></span>
                    <span class="hidden-xs">${text.escape(i18n.translate(BundleHelper.companyName))}</span>
                </a>
                <c:if test="${not empty kapp}">
                    <a class="kapp-home-link" href="${bundle.kappLocation}">
                        <span>${text.escape(i18n.translate(kapp.name))}</span>
                    </a>
                </c:if>
            </div>

            <%-- Right Hand Navigation --%>
            <div class="right-nav">
                <ul class="nav navbar-nav navbar-right">

                    <%--***** START RIGHT HAND NAV *****--%>
                    
                    <%--***** END RIGHT HAND NAV *****--%>
                    
                    <%-- User Details Dropdown Tile and Links --%>
                    <li class="dropdown hidden-xs clearfix">
                        <c:choose>
                            <c:when test="${identity.anonymous}">
                                <a href="${bundle.spaceLocation}/app/login">
                                    <span class="fa fa-sign-in fa-fw"></span>
                                    <span>${i18n.translate('Login')}</span>
                                </a>
                            </c:when>
                            <c:otherwise>
                                <a id="user-menu" href="javascript:void(0);" class="dropdown-toggle"
                                   data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">
                                    ${GravatarHelper.get(36)}
                                </a>
                                <div class="dropdown-menu dropdown-menu-right user-tile" aria-labelledby="user-menu">
                                    <div>
                                        <div><b>${text.defaultIfBlank(identity.displayName, identity.username)}</b></div>
                                        <div>${identity.email}</div>
                                    </div>
                                    <div class="actions">
                                        <a class="" href="${bundle.spaceLocation}/?page=profile">
                                            <span class="fa fa-user fa-fw"></span>
                                            <span>${i18n.translate('Profile')}</span>
                                        </a>
                                        <a class="pull-right" href="${bundle.spaceLocation}/app/logout">
                                            <span class="fa fa-sign-out fa-fw"></span>
                                            <span>${i18n.translate('Logout')}</span>
                                        </a>
                                    </div>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </li>
                </ul>
            </div>
        </div>

        <%-- Mobile Menu Navigation --%>
        <div class="collapse navbar-collapse" id="bundle-header-drawer">
            <ul class="nav navbar-nav hidden-sm hidden-md hidden-lg">
                <%-- Navigation links defined in navigation.jsp --%>
                <c:import url="${headerPath}/partials/navigation.jsp" charEncoding="UTF-8" />
            </ul>
        </div>

    </div>
</nav>
