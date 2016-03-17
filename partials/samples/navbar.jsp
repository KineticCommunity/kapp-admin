<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<section class="configbar">
    <div class="container-fluid">
        <ul class="nav nav-tabs">
            <li class="${param.page == 'samples/dashboard' ? 'active' : ''}">
                <a href="${bundle.kappLocation}?page=samples/dashboard">Dashboard</a>
            </li>
            <li class="${param.page == 'samples/build' ? 'active' : ''}">
                <a href="${bundle.kappLocation}?page=samples/build">Build</a>
            </li>
            <li class="${param.page == 'samples/setup' ? 'active' : ''}">
                <a href="${bundle.kappLocation}?page=samples/setup">Setup</a>
            </li>
        </ul>
    </div>
</section>