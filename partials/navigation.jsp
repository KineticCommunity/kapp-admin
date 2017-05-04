<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../bundle/initialization.jspf" %>
<c:set var="adminKapp" value="${space.getKapp(space.getAttributeValue('Admin Kapp Slug'))}" />

<%-- Link to Space Page --%>
<li><a href="${bundle.spaceLocation}">
    <span class="fa fa-fw fa-home"></span>
    ${i18n.translate(AdminHelper.companyName)}</a>
</li>
<li class="divider"></li>
<%-- Link to Each Kapp --%>
<c:forEach items="${space.kapps}" var="kappLink">
    <c:if test="${not text.equals(kappLink.slug, adminKapp.slug)}">
        <li><a href="${bundle.spaceLocation}/${kappLink.slug}">
            <span class="fa fa-fw ${text.defaultIfBlank(kappLink.getAttributeValue('Icon'), 'fa-default-kapp')}"></span>
            ${i18n.translate(kappLink.name)}</a>
        </li>
    </c:if>
</c:forEach>
<%-- Link to Administrative Consoles --%>
<c:if test="${identity.spaceAdmin}">
    <li class="divider"></li>
    <c:if test="${adminKapp != null}">
        <li><a href="${bundle.spaceLocation}/${adminKapp.slug}">
            <span class="fa fa-fw ${text.defaultIfBlank(adminKapp.getAttributeValue('Icon'), 'fa-kinetic-admin')}"></span>
            ${i18n.translate('Admin Console')}
        </a></li>
    </c:if>
</c:if>

<%-- Login/Logout and Profile Links (Visible here for Mobile only) --%>
<li class="divider hidden-sm hidden-md hidden-lg"></li>
<c:choose>
    <c:when test="${identity.anonymous}">
        <li class="hidden-sm hidden-md hidden-lg">
            <a href="${bundle.spaceLocation}/app/login">
                <span class="fa fa-sign-in fa-fw"></span>
                ${i18n.translate('Login')}
            </a>
        </li>
    </c:when>
    <c:otherwise>
        <li class="hidden-sm hidden-md hidden-lg">
            <a href="${bundle.spaceLocation}?page=profile">
                <span class="fa fa-user fa-fw"></span>
                ${i18n.translate('Profile')}
            </a>
        </li>
        <li class="hidden-sm hidden-md hidden-lg">
            <a href="${bundle.spaceLocation}/app/logout">
                <span class="fa fa-sign-out fa-fw"></span>
                ${i18n.translate('Logout')}
            </a>
        </li>
    </c:otherwise>
</c:choose>
