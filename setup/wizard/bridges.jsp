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
                <c:choose>
                    <c:when test="${bridge.exists}">
                        <c:set var="bridge" value="${space.getBridge(bridge.name)}"/>
                        <c:set var="status" value="${true}"/>
                    </c:when>
                    <c:otherwise><c:set var="status" value="${false}"/></c:otherwise>
                </c:choose>
                <tr data-status="${status}" data-name="${bridge.name}" data-status-value="${bridge.status}" class="${status ? 'success' : 'warning'}">
                    <td>${bridge.name}</td>
                    <td>${bridge.status}</td>
                    <c:choose>
                        <c:when test="${status}">
                            <td>
                                ${bridge.url}
                            </td>
                            <td>
                                <span class="label label-success"><span class="fa fa-check"></span> Configured</span>
                            </td>
                        </c:when>
                        <c:otherwise>
                            <td>
                        <input type="text" class="form-control" placeholder="Bridge Url" value="${bridge.url}">
                            </td>
                            <td>
                                <span class="label label-danger"><span class="fa fa-times"></span> Not Configured</span>
                            </td>
                        </c:otherwise>
                    </c:choose>
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
                <c:set var="json" value="${Text.escape(Json.toString(bridgeModel))}"/>
                <c:choose>
                    <c:when test="${bridgeModel.exists}">
                        <c:set var="bridgeModel" value="${space.getBridgeModel(bridgeModel.name)}"/>
                        <c:set var="status" value="${true}"/>
                    </c:when>
                    <c:otherwise><c:set var="status" value="${false}"/></c:otherwise>
                </c:choose>
                <tr data-json="${status ? '' : json}" data-status="${status}" class="${status ? 'success' : 'warning'}">
                    <td>${bridgeModel.name}</td>
                    <td>${bridgeModel.status}</td>
                    <td>${bridgeModel.activeMappingName}</td>
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
                    <c:set var="json" value="${Text.escape(Json.toString(bridgeMapping))}"/>
                    <c:choose>
                        <c:when test="${bridgeMapping.exists}">
                            <c:set var="bridgeMapping" value="${space.getBridgeModelMapping(bridgeModel.name, bridgeMapping.name)}"/>
                            <c:set var="status" value="${true}"/>
                        </c:when>
                        <c:otherwise><c:set var="status" value="${false}"/></c:otherwise>
                    </c:choose>
                    <tr data-json="${status ? '' : json}" data-model-name="${bridgeModel.name}" 
                            data-status="${status}" class="${status ? 'success' : 'warning'}">
                        <td>${bridgeModel.name}</td>
                        <td>${bridgeMapping.name}</td>
                        <td>${bridgeMapping.bridgeName}</td>
                        <td>${bridgeMapping.structure}</td>
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
            </c:forEach>
        </tbody>
    </table>
</div>

<c:import url="${bundle.path}/setup/wizard/navigation.jsp" charEncoding="UTF-8"/>