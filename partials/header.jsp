<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../bundle/initialization.jspf" %>

<nav class="navbar navbar-default" id="bundle-header">
    <div class="container">
        <div class="navbar-header">
            <button type="button" class="navbar-toggle dropdown" data-toggle="collapse"
            data-target="#navbar-collapse-1" aria-expanded="false">
            <span class="sr-only">${i18n.translate('Toggle navigation')}</span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
            </button>
            <a class="navbar-brand" href="${not empty kapp ? bundle.kappLocation : bundle.spaceLocation}">
                <c:choose>
                    <c:when test="${not empty kapp && kapp.hasAttribute('Logo Url')}">
                        <img src="${space.getAttributeValue('Logo Url')}" alt="${text.escape(i18n.translate(kapp.name))}">
                    </c:when>
                    <c:when test="${space.hasAttribute('Logo Url')}">
                        <img src="${kapp.getAttributeValue('Logo Url')}" alt="${text.escape(i18n.translate(space.name))}">
                    </c:when>
                    <c:when test="${not empty kapp}">
                        <span class="fa fa-home fa-fw"></span>
                        <span>${text.escape(i18n.translate(kapp.name))}</span>
                    </c:when>
                    <c:otherwise>
                        <span class="fa fa-home fa-fw"></span>
                        <c:choose>
                            <c:when test="${not empty kapp && kapp.hasAttribute('Company Name')}">
                                <span>${text.escape(i18n.translate(kapp.getAttributeValue('Company Name')))}</span>
                            </c:when>
                            <c:when test="${space.hasAttribute('Company Name')}">
                                <span>${text.escape(i18n.translate(space.getAttributeValue('Company Name')))}</span>
                            </c:when>
                            <c:when test="${not empty kapp}">
                                <span>${text.escape(i18n.translate(kapp.name))}</span>
                            </c:when>
                            <c:otherwise>
                                <span>${text.escape(i18n.translate(space.name))}</span>
                            </c:otherwise>
                        </c:choose>
                    </c:otherwise>
                </c:choose>
            </a>
        </div>

        <div class="collapse navbar-collapse" id="navbar-collapse-1">
            <ul class="nav navbar-nav navbar-right">
                <li class="dropdown">
                    <c:choose>
                        <c:when test="${identity.anonymous}">
                            <a href="${bundle.spaceLocation}/app/login" class="hidden-xs">
                                <span class="fa fa-sign-in fa-fw"></span> 
                                <span>${i18n.translate('Login')}</span>
                            </a>
                        </c:when>
                        <c:otherwise>
                            <a id="userMenu" href="#" class="dropdown-toggle hidden-xs" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">
                                <span class="fa fa-user fa-fw"></span>
                                <span>${text.escape(text.trim(identity.displayName, identity.username))}</span>
                                <span class="fa fa-caret-down fa-fw"></span>
                            </a>
                            <ul class="dropdown-menu show-xs priority" aria-labelledby="userMenu">
                                <li class="hidden-xs">
                                    <a href="${bundle.spaceLocation}/?page=profile">
                                        <span class="fa fa-pencil fa-fw"></span>
                                        <span>${i18n.translate('Edit Profile')}</span>
                                    </a>
                                </li>
                                <li class="priority hidden-lg hidden-md hidden-sm">
                                    <a href="${bundle.spaceLocation}/?page=profile">
                                        <span class="fa fa-user fa-fw"></span> 
                                        <span>${i18n.translate('Profile')}</span>
                                    </a>
                                </li>
                                <li class="divider hidden-xs"></li>
                                <li class="hidden-xs">
                                    <a href="${bundle.spaceLocation}/app/">
                                        <span class="fa fa-dashboard fa-fw"></span>
                                        <span>${i18n.translate('Management Console')}</span>
                                    </a>
                                </li>
                                <li class="divider hidden-xs"></li>
                                <li>
                                    <a href="${bundle.spaceLocation}/app/logout">
                                        <span class="fa fa-sign-out fa-fw"></span>
                                        <span>${i18n.translate('Logout')}</span>
                                    </a>
                                </li>
                            </ul>
                        </c:otherwise>
                    </c:choose>
                </li>
                <li class="dropdown">
                    <a id="linkMenu" href="#" class="dropdown-toggle  hidden-xs" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">
                        <span class="hidden-xs fa fa-th fa-fw"></span>
                    </a>
                    <ul class="dropdown-menu show-xs" aria-labelledby="linkMenu">
                        <li>
                            <a href="${bundle.spaceLocation}">
                                ${i18n.translate('Home')}
                            </a>
                        </li>
                        <c:catch var="headerNavigationError">
                            <c:forEach items="${BundleHelper.headerNavigation}" var="link">
                                <li>
                                    <a href="${link.path}">${i18n.translate(link.name)}</a>
                                </li>
                            </c:forEach>
                        </c:catch>
                        <c:if test="${headerNavigationError ne null}">
                            <li class="alert alert-danger">${i18n.translate('Error building header navigation. The value of the \"Header Navigation List\" attribute contains invalid JSON.')}</li>
                        </c:if>
                        <c:if test="${identity.spaceAdmin}">
                            <li class="divider hidden-xs"></li>
                            <li class="dropdown-header">${i18n.translate('KAPPS')}</li>                                    
                            <c:forEach items="${space.kapps}" var="kapp" begin="0" end="8">
                                <li><a href="${bundle.spaceLocation}/${kapp.slug}">${i18n.translate(kapp.name)}</a></li>
                            </c:forEach>
                        </c:if>
                    </ul>
                </li>
            </ul>
        </div>
    </div>
</nav>