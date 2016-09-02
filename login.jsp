<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="bundle/initialization.jspf" %>
<bundle:layout page="layouts/layout.jsp">
    <bundle:variable name="head">
        <title>${text.escape(kapp.name)} Login</title>
    </bundle:variable>
    <div class="container">
        <div class="row">
            <div class="col-md-6 col-md-offset-3">
                <form id="kinetic-login" action="<c:url value="${space.slug}/app/login.do"/>" method="POST">
                    <div class="profile panel panel-default">
                        <div class="panel-heading">
                            <h2>Login</h2>
                        </div>
                        <div class="panel-body">
                            <!-- CSRF Token field -->
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
            
                            <!-- Space to login to -->
                            <input type="hidden" name="j_space" value="${space.slug}"/>
            
                            <!-- Kapp to login to -->
                            <input type="hidden" name="j_kapp" value="${kapp.slug}"/>
            
                            <!-- Username field -->
                            <div class="form-group">
                                <label for="j_username" class="control-label">Username</label>
                                <input type="text" name="j_username" id="j_username" class="form-control" autofocus/>
                            </div>
            
                            <!-- Password field -->
                            <div class="form-group">
                                <label for="j_password" class="control-label">Password</label>
                                <input type="password" name="j_password" id="j_password" class="form-control" autocomplete="off"/>
                            </div>
                        </div>
                        <div class="panel-footer text-right">
                            <!-- Login button -->
                            <div class="form-group">
                                <button type="submit" class="btn btn-default">Login</button>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</bundle:layout>
