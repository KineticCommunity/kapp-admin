<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<hr /><c:import url="${bundle.path}/setup/wizard/progress.jsp" charEncoding="UTF-8"/><hr />

<!-- Webhooks -->
<div class="webhooks text-left">
    <h3>Webhooks</h3>
    <table class="table table-hover">
        <thead>
            <tr>
                <th>Level</th>
                <th>Name</th>
                <th>Type</th>
                <th>Event</th>
                <th width="10%"></th>
            </tr>
        </thead>
        <tbody>
            <!-- SPACE WEBHOOKS -->
            <c:forEach items="${SetupHelper.getSpaceWebhooks()}" var="webhook">
                <c:set var="spaceWebhookStatus" value="${not empty space.getWebhook(webhook.name)}"/>
                <tr data-json="${Text.escape(Json.toString(webhook))}" data-level="space" data-status="${spaceWebhookStatus}" class="${spaceWebhookStatus ? 'success' : 'danger'}">
                    <td>Space</td>
                    <td>${webhook.name}</td>
                    <td>${webhook.type}</td>
                    <td>${webhook.event}</td>
                    <td>
                        <c:choose>
                            <c:when test="${spaceWebhookStatus}">
                                <span class="label label-success"><span class="fa fa-check"></span> Configured</span>
                            </c:when>
                            <c:otherwise>
                                <span class="label label-danger"><span class="fa fa-times"></span> Not Configured</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                </tr>
            </c:forEach>
            <!-- KAPP WEBHOOKS -->
            <c:forEach items="${SetupHelper.getKappWebhooks()}" var="webhook">
                <c:set var="kappWebhookStatus" value="${not empty kapp.getWebhook(webhook.name)}"/>
                <tr data-json="${Text.escape(Json.toString(webhook))}" data-level="kapp" data-status="${kappWebhookStatus}" class="${kappWebhookStatus ? 'success' : 'danger'}">
                    <td>Space</td>
                    <td>${webhook.name}</td>
                    <td>${webhook.type}</td>
                    <td>${webhook.event}</td>
                    <td>
                        <c:choose>
                            <c:when test="${kappWebhookStatus}">
                                <span class="label label-success"><span class="fa fa-check"></span> Configured</span>
                            </c:when>
                            <c:otherwise>
                                <span class="label label-danger"><span class="fa fa-times"></span> Not Configured</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</div>

<c:import url="${bundle.path}/setup/wizard/navigation.jsp" charEncoding="UTF-8"/>