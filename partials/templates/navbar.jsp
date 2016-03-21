<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<!-- 
    Tabbed header at the top. Highest level of navigation within an Admin Console. 
    Use this file only if you have multiple pages in the console.
-->
<section class="configbar">
    <div class="container-fluid">
        <ul class="nav nav-tabs">
            <li class="${text.equals(param.page, 'templates/console') ? 'active' : ''}">
                <a href="${bundle.kappLocation}?page=templates/console">Home</a>
            </li>
            <li class="${text.equals(param.page, 'templates/pagetwo') ? 'active' : ''}">
                <a href="${bundle.kappLocation}?page=templates/pagetwo">Page Two</a>
            </li>
        </ul>
    </div>
</section>