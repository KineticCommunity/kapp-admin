<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="bundle/initialization.jspf" %>
<bundle:layout page="layouts/layout.jsp">
    <bundle:variable name="pageTitle">${text.escape(i18n.translate('Login'))}</bundle:variable>
    <div class="container m-y-4">
        <div class="row login">
            <div class="col-md-6 col-md-offset-3">
                <div class="card card-primary card-subtle">
                    <div class="card-title text-center"><h1>${i18n.translate('Login')}</h1></div>
                    <div class="card-content">
                        <form action="<c:url value="${bundle.spacePath}/app/login.do"/>" method="POST">
                            <!-- CSRF Token field -->
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                            <!-- Space to login to -->
                            <input type="hidden" name="j_space" value="${space.slug}"/>
                            <!-- Kapp to login to -->
                            <input type="hidden" name="j_kapp" value="${kapp.slug}"/>
                            <!-- Username field -->
                            <div class="form-group">
                                <label for="j_username">${i18n.translate('Username')}</label>
                                <input type="text" name="j_username" id="j_username" class="form-control" autofocus/>
                            </div>
                            <!-- Password field -->
                            <div class="form-group">
                                <label for="j_password">${i18n.translate('Password')}</label>
                                <input type="password" name="j_password" id="j_password" class="form-control" autocomplete="off"/>
                            </div>
                            <div class="form-group pull-left">
                                <button id="submit" type="submit" class="btn btn-default">${i18n.translate('Login')}</button>
                            </div>
                            <p class="pull-right">
                                <a href="<c:url value="/${space.slug}/app/reset-password"/>">${i18n.translate('Reset Password')}</a>
                            </p>
                        </form>
                    </div>
                    <%--
                        Display error message if authentication error is found in 
                        URL.  This happens if login credentials are invalid.
                    --%>
                    <c:if test="${param.authentication_error != null}">
                        <script>
                            $("form").notifie({
                                type:"alert",
                                severity:"info",
                                message: K.translate("bundle", "Invalid username or password.")
                            });
                        </script>
                    </c:if>
                </div>
            </div>
        </div>
    </div>    
</bundle:layout>
