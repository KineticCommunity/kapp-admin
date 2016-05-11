<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../bundle/initialization.jspf" %>

<footer>
    <div class="container-fluid">
        <p>
            ${text.escape(kapp.title)}
            
            <span class="pull-right">
                v1.0.0dev
            </span>
        </p>
    </div>
</footer>