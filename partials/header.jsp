<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../bundle/initialization.jspf" %>

<nav class="navbar navbar-default" role="navigation">
    <h2 class="kapp-title">${text.escape(kapp.name)}</h2>
    
    <ul class="nav navbar-nav navbar-right">
        <li class="dropdown">
            <a class="dropdown-toggle" data-toggle="dropdown">
                <div class="avatar">
                    <img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHBvaW50ZXItZXZlbnRzPSJub25lIiB3aWR0aD0iMzBweCIgaGVpZ2h0PSIzMHB4IiBzdHlsZT0iYmFja2dyb3VuZC1jb2xvcjogcmdiKDIyLCAxNjAsIDEzMyk7Ij48dGV4dCB0ZXh0LWFuY2hvcj0ibWlkZGxlIiB5PSI1MCUiIHg9IjUwJSIgZHk9IjAuMzVlbSIgcG9pbnRlci1ldmVudHM9ImF1dG8iIGZpbGw9IiNmZmZmZmYiIGZvbnQtZmFtaWx5PSJIZWx2ZXRpY2FOZXVlLUxpZ2h0LEhlbHZldGljYSBOZXVlIExpZ2h0LEhlbHZldGljYSBOZXVlLEhlbHZldGljYSwgQXJpYWwsTHVjaWRhIEdyYW5kZSwgc2Fucy1zZXJpZiIgc3R5bGU9ImZvbnQtd2VpZ2h0OiA0MDA7IGZvbnQtc2l6ZTogMTRweDsiPkI8L3RleHQ+PC9zdmc+" style="border-radius:30px;">
                </div>
                <div class="account">
                    <span>${text.escape(identity.username)}</span>
                    <span class="fa fa-caret-down"></span>
                    <ul class="dropdown-menu">
                        <li>Profile</li>
                        <li>Logout</li>
                    </ul>
                </div>
            </a>
        </li>
    </ul>
</nav>
