<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<p class="text-center setup-actions">
    <a href="${bundle.kappLocation}?setup=wizard&step=${SetupHelper.getWizardNextStep(param.step)}" 
            class="btn btn-md btn-subtle pull-right">
        <b>${SetupHelper.isWizardLastStep(param.step) ? 'Finish ' : 'Next '}<span class="fa fa-caret-right"></span><b>
    </a>
    <button href="${bundle.kappLocation}?setup=wizard&step=${SetupHelper.getWizardNextStep(param.step)}" 
            class="btn btn-md btn-primary save-configuration">
        <b><span class="fa fa-floppy-o"></span> Save Configuration<b>
    </button>
    <a href="${bundle.kappLocation}?setup=wizard&step=${SetupHelper.getWizardPreviousStep(param.step)}" 
            class="btn btn-md btn-subtle pull-left">
        <b><span class="fa fa-caret-left"></span> Previous<b>
    </a>
</p>