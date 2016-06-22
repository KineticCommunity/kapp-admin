<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<div class="wizard-progress text-center">

    <a href="${bundle.kappLocation}?setup=wizard" 
            class="btn btn-sm btn-${Text.equals(param.step, 'home') ? 'default' : 'subtle'}">
        <c:if test="${Text.equals(param.step, 'home')}"><b></c:if>
        <span class="fa fa-home"></span> Home
        <c:if test="${Text.equals(param.step, 'home')}"></b><c:set var="futurePage" value="future-page"/></c:if>
    </a>

    <c:forEach var="progress" items="${SetupHelper.getWizardProgress()}">
    
        <span class="fa fa-caret-right"></span>
        <a href="${bundle.kappLocation}?setup=wizard&step=${progress.slug}" 
                class="${futurePage} btn btn-sm btn-${Text.equals(param.step, progress.slug) ? 'default' : (progress.configured ? 'success' : 'danger')}">
            <c:if test="${Text.equals(param.step, progress.slug)}"><b></c:if>
            <span class="fa fa-${progress.configured ? 'check' : 'times'}"></span> ${progress.name}
            <c:if test="${Text.equals(param.step, progress.slug)}"></b><c:set var="futurePage" value="future-page"/></c:if>
        </a>
            
    </c:forEach>

</div>