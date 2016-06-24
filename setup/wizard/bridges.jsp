<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<hr /><c:import url="${bundle.path}/setup/wizard/progress.jsp" charEncoding="UTF-8"/><hr />

<!-- BRIDGES -->
<div class="bridges text-left">
    <h3>Bridges</h3>
    <table class="table table-hover">
        <thead>
            <tr>
                <th>Name</th>
                <th>Status</th>
                <th>Url</th>
                <th width="10%"></th>
            </tr>
        </thead>
        <tbody>
            <c:forEach items="${SetupHelper.bridges}" var="bridge">
                <tr data-json="${Text.escape(Json.toString(bridge))}" class="${bridge.exists ? 'success' : 'danger'}">
                    <td>${bridge.name}</td>
                    <td>${bridge.status}</td>
                    <td>
                        <input type="text" class="form-control" placeholder="Bridge Url" value="${bridge.url}">
                    </td>
                    <td>
                        <c:choose>
                            <c:when test="${bridge.exists}">
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
<hr /> 
<!-- BRIDGE MODELS -->
<div class="bridge-models text-left">
    <h3>Bridge Models</h3>
    <table class="table table-hover">
        <thead>
            <tr>
                <th>Model Name</th>
                <th>Status</th>
                <th>Active Mapping Name</th>
                <th width="10%"></th>
            </tr>
        </thead>
        <tbody>
            <c:forEach items="${SetupHelper.bridgeModels}" var="bridgeModel">
                <tr data-json="${Text.escape(Json.toString(bridgeModel))}" class="${bridgeModel.exists ? 'success' : 'danger'}">
                    <td>${bridgeModel.name}</td>
                    <td>${bridgeModel.status}</td>
                    <td>${bridgeModel.activeMappingName}</td>
                    <td>
                        <c:choose>
                            <c:when test="${bridgeModel.exists}">
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
<hr /> 
<div class="bridge-mappings text-left">
    <h3>Bridge Mappings</h3>
    <table class="table table-hover">
        <thead>
            <tr>
                <th>Model Name</th>
                <th>Mapping Name</th>
                <th>Bridge Name</th>
                <th>Structure</th>
                <th width="10%"></th>
            </tr>
        </thead>
        <tbody>
            <c:forEach items="${SetupHelper.bridgeModels}" var="bridgeModel">
                <c:forEach items="${bridgeModel.mappings}" var="bridgeMapping">
                    <tr data-status="${bridgeMapping.exists}" class="${bridgeMapping.exists ? 'success' : 'danger'}">
                        <td>${bridgeModel.name}</td>
                        <td>${bridgeMapping.name}</td>
                        <td>${bridgeMapping.bridgeName}</td>
                        <td>${bridgeMapping.structure}</td>
                        <td>
                            <c:choose>
                                <c:when test="${bridgeMapping.exists}">
                                    <span class="label label-success"><span class="fa fa-check"></span> Configured</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="label label-danger"><span class="fa fa-times"></span> Not Configured</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                </c:forEach>
            </c:forEach>
        </tbody>
    </table>
</div>

<c:import url="${bundle.path}/setup/wizard/navigation.jsp" charEncoding="UTF-8"/>