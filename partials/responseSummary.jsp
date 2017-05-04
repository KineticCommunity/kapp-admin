<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../bundle/initialization.jspf" %>
<div id="response-container" data-ng-app="kd.discussion">
    <!-- The response-issue-view renders the message/chatroom view.
        -- response-server: the URL to the Response server.
        -- current-issue-id: a variable or single-quoted string containing the GUID of the issue
        -- embed-padding: The number of pixels to pad from the bottom for the fixed height message view.
        -->
<%--     <response-issue-view response-server="${BundleHelper.responseUrl}" current-issue-id="${responseId}" embed-padding="75"></response-issue-view> --%>
    <response-server base="'${AdminHelper.responseUrl}'" watch-issue="'${responseId}'">
    	<issue-summary summary-issue="$parent.response.issue" current-user="$parent.response.currentUser" no-title="true"></issue-summary>
    </response-server>
    
    <bundle:variable name="head">
        <!-- This loads Response + Angular. -->
        <script src="${headerLocation}/js/response_bundle.js"></script>
        <!-- This defines the application which will render the Response components (and other Angular functionality as needed). -->
        <script>
            angular.module("kd.discussion", [
                // This is tells your application, kd.sample, that it needs kd.response in order to render the components.
                "kd.response"
            ]);
        </script>   
    </bundle:variable>
</div>