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
                <c:set var="json" value="${Text.escape(Json.toString(webhook))}"/>
                <c:choose>
                    <c:when test="${not empty space.getWebhook(webhook.name)}">
                        <c:set var="webhook" value="${space.getWebhook(webhook.name)}"/>
                        <c:set var="status" value="${true}"/>
                    </c:when>
                    <c:otherwise><c:set var="status" value="${false}"/></c:otherwise>
                </c:choose>
                <tr data-json="${status ? '' : json}" data-level="space" data-status="${status}" class="${status ? 'success' : 'warning'}">
                    <td>Space</td>
                    <td>${webhook.name}</td>
                    <td>${webhook.type}</td>
                    <td>${webhook.event}</td>
                    <td>
                        <c:choose>
                            <c:when test="${status}">
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
                <c:set var="json" value="${Text.escape(Json.toString(webhook))}"/>
                <c:choose>
                    <c:when test="${not empty kapp.getWebhook(webhook.name)}">
                        <c:set var="webhook" value="${kapp.getWebhook(webhook.name)}"/>
                        <c:set var="status" value="${true}"/>
                    </c:when>
                    <c:otherwise><c:set var="status" value="${false}"/></c:otherwise>
                </c:choose>
                <tr data-json="${status ? '' : json}" data-level="kapp" data-status="${status}" class="${status ? 'success' : 'warning'}">
                    <td>Space</td>
                    <td>${webhook.name}</td>
                    <td>${webhook.type}</td>
                    <td>${webhook.event}</td>
                    <td>
                        <c:choose>
                            <c:when test="${status}">
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