<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../bundle/initialization.jspf" %>

<!-- 
    Left sidebar navigation. This file is specifically configured for kapp navigation. 
    If you need different types of navigation in this sidebar, create your own version of this sidebar file in the partials folder of your console.
    This level of navigation uses the same page, but adds a kapp url parameter.
-->
<div>
    <ul class="nav nav-pills nav-stacked">
        <c:forEach var="kapp" items="${space.kapps}">
            <li class="${kapp.slug eq currentKapp.slug ? 'active' : ''}">
                <a href="?page=${param.page}&kapp=${kapp.slug}">${kapp.name}</a>
            </li>
        </c:forEach>
    </ul>
</div>