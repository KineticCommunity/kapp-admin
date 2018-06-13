<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="bundle/initialization.jspf" %>
<bundle:layout page="layouts/layout.jsp">
    <bundle:variable name="pageTitle">${text.escape(i18n.translate('Reset Password'))}</bundle:variable>
    <div class="container m-y-4">
        <div class="row login reset-password">
            <div class="col-md-6 col-md-offset-3">
                <div class="card card-primary card-subtle">
                    <h1 class="text-center card-title">${i18n.translate('Password Reset')}</h1>
                    <c:choose>
                        <%-- REQUEST RESET PASSWORD TOKEN --%>
                        <c:when test="${param.token == null && param.confirmation == null}">
                            <form  class="card-content" action="<c:url value="${bundle.spaceLocation}/app/reset-password"/>" method="POST">
                                <!-- Username field -->
                                <div class="form-group">
                                    <label for="username">${i18n.translate("Username")}</label>
                                    <input name="username" type="text" id="username" class="form-control" autofocus value="${param.username}"/>
                                </div>
                                <!-- Hidden fields -->
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                <!-- Submit Buttons -->
                                <div class="form-group">
                                    <button type="submit" class="btn btn-default">${i18n.translate("Submit")}</button>
                                    <a class="pull-right" href="<c:url value="${bundle.spaceLocation}/app/reset-password?confirmation"/>">${i18n.translate('I already have a reset code.')}</a>
                                </div>
                            </form>
                        </c:when>
                        <%-- RESET PASSWORD --%>
                        <c:otherwise>
                            <!-- Password reset confirmation -->
                            <form  class="card-content" action="<c:url value="${bundle.spaceLocation}/app/reset-password/token"/>" method="POST">
                                <p>
                                    ${i18n.translate('You will receive an email with a unique code which will enable you to reset your password. Type that password into the token field and enter your new desired password.')}
                                </p>
    
                                <!-- Passwords not matching -->
                                <c:if test="${param.nomatch != null}">
                                    <div class="alert alert-danger">
                                        ${i18n.translate('Your passwords did not match.')}
                                    </div>
                                </c:if>
    
                                <!-- Username field -->
                                <div class="form-group">
                                    <label for="username">${i18n.translate("Username")}</label>
                                    <input name="username" type="text" id="username" class="form-control" value="${param.username}"/>
                                </div>
                                <!-- Token field -->
                                <div class="form-group">
                                    <label for="token">${i18n.translate("Password Token")}</label>
                                    <input type="text" name="token" id="token" class="form-control" autofocus value="${param.token}"/>
                                </div>
                                <!-- Password field -->
                                <div class="form-group">
                                    <label for="password">${i18n.translate("New Password")}</label>
                                    <input type="password" name="password" id="password" class="form-control"/>
                                </div>
                                <!-- Password Confirmation field -->
                                <div class="form-group">
                                    <label for="confirmPassword">${i18n.translate("Confirm Password")}</label>
                                    <input type="password" name="confirmPassword" id="confirmPassword" class="form-control"/>
                                </div>
    
                                <!-- Hidden fields -->
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                
                                <!-- Submit Buttons -->
                                <div class="form-group">
                                    <button type="submit" class="btn btn-default">${i18n.translate("Submit")}</button>
                                    <a class="pull-right" href="<c:url value="${bundle.spaceLocation}/app/reset-password"/>">${i18n.translate("I don't have a reset code.")}</a>
                                </div>
                            </form>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
</bundle:layout>
