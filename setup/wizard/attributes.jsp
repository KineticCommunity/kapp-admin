<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<hr /><c:import url="${bundle.path}/setup/wizard/progress.jsp" charEncoding="UTF-8"/><hr />

<!-- ATTRIBUTE DEFINITIONS -->
<div class="attribute-definitions text-left">
    <h3>Attribute Definitions</h3>
    <table class="table table-hover">
        <thead>
            <tr>
                <th>Level</th>
                <th>Name</th>
                <th>Description</th>
                <th>Allows Multiple</th>
                <th width="10%"></th>
            </tr>
        </thead>
        <tbody>
            <!-- SPACE ATTRIBUTE DEFINITIONS -->
            <c:forEach items="${SetupHelper.getSpaceAttributeDefinitions()}" var="attributeDefinition">
                <tr data-name="${attributeDefinition.name}" data-allows-multiple="${attributeDefinition.isAllowsMultiple()}" data-status="${attributeDefinition.isDefinitionExists()}"
                        data-level="space" class="space-attribute-definition ${attributeDefinition.isDefinitionExists() ? 'success' : 'danger'}">
                    <td>Space</td>
                    <td>${attributeDefinition.name}</td>
                    <td>${attributeDefinition.description}</td>
                    <td>${attributeDefinition.isAllowsMultiple() ? 'Yes' : 'No'}</td>
                    <td>
                        <c:choose>
                            <c:when test="${attributeDefinition.isDefinitionExists()}">
                                <span class="label label-success"><span class="fa fa-check"></span> Configured</span>
                            </c:when>
                            <c:otherwise>
                                <span class="label label-danger"><span class="fa fa-times"></span> Not Configured</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                </tr>
            </c:forEach>
            <!-- KAPP ATTRIBUTE DEFINITIONS -->
            <c:forEach items="${SetupHelper.getKappAttributeDefinitions()}" var="attributeDefinition">
                <tr data-name="${attributeDefinition.name}" data-allows-multiple="${attributeDefinition.isAllowsMultiple()}" data-status="${attributeDefinition.isDefinitionExists()}"
                        data-level="kapp" class="kapp-attribute-definition ${attributeDefinition.isDefinitionExists() ? 'success' : 'danger'}">
                    <td>Kapp</td>
                    <td>${attributeDefinition.name}</td>
                    <td>${attributeDefinition.description}</td>
                    <td>${attributeDefinition.isAllowsMultiple() ? 'Yes' : 'No'}</td>
                    <td>
                        <c:choose>
                            <c:when test="${attributeDefinition.isDefinitionExists()}">
                                <span class="label label-success"><span class="fa fa-check"></span> Configured</span>
                            </c:when>
                            <c:otherwise>
                                <span class="label label-danger"><span class="fa fa-times"></span> Not Configured</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                </tr>
            </c:forEach>
            <!-- FORM ATTRIBUTE DEFINITIONS -->
            <c:forEach items="${SetupHelper.getFormAttributeDefinitions()}" var="attributeDefinition">
                <tr data-name="${attributeDefinition.name}" data-allows-multiple="${attributeDefinition.isAllowsMultiple()}" data-status="${attributeDefinition.isDefinitionExists()}"
                        data-level="form" class="form-attribute-definition ${attributeDefinition.isDefinitionExists() ? 'success' : 'danger'}">
                    <td>Form</td>
                    <td>${attributeDefinition.name}</td>
                    <td>${attributeDefinition.description}</td>
                    <td>${attributeDefinition.isAllowsMultiple() ? 'Yes' : 'No'}</td>
                    <td>
                        <c:choose>
                            <c:when test="${attributeDefinition.isDefinitionExists()}">
                                <span class="label label-success"><span class="fa fa-check"></span> Configured</span>
                            </c:when>
                            <c:otherwise>
                                <span class="label label-danger"><span class="fa fa-times"></span> Not Configured</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                </tr>
            </c:forEach>
            <!-- CATEGORY ATTRIBUTE DEFINITIONS -->
            <c:forEach items="${SetupHelper.getCategoryAttributeDefinitions()}" var="attributeDefinition">
                <tr data-name="${attributeDefinition.name}" data-allows-multiple="${attributeDefinition.isAllowsMultiple()}" data-status="${attributeDefinition.isDefinitionExists()}"
                        data-level="category" class="cateogry-attribute-definition ${attributeDefinition.isDefinitionExists() ? 'success' : 'danger'}">
                    <td>Category</td>
                    <td>${attributeDefinition.name}</td>
                    <td>${attributeDefinition.description}</td>
                    <td>${attributeDefinition.isAllowsMultiple() ? 'Yes' : 'No'}</td>
                    <td>
                        <c:choose>
                            <c:when test="${attributeDefinition.isDefinitionExists()}">
                                <span class="label label-success"><span class="fa fa-check"></span> Configured</span>
                            </c:when>
                            <c:otherwise>
                                <span class="label label-danger"><span class="fa fa-times"></span> Not Configured</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                </tr>
            </c:forEach>
            <!-- USER ATTRIBUTE DEFINITIONS -->
            <c:forEach items="${SetupHelper.getUserAttributeDefinitions()}" var="attributeDefinition">
                <tr data-name="${attributeDefinition.name}" data-allows-multiple="${attributeDefinition.isAllowsMultiple()}" data-status="${attributeDefinition.isDefinitionExists()}"
                        data-level="user" class="user-attribute-definition ${attributeDefinition.isDefinitionExists() ? 'success' : 'danger'}">
                    <td>User</td>
                    <td>${attributeDefinition.name}</td>
                    <td>${attributeDefinition.description}</td>
                    <td>${attributeDefinition.isAllowsMultiple() ? 'Yes' : 'No'}</td>
                    <td>
                        <c:choose>
                            <c:when test="${attributeDefinition.isDefinitionExists()}">
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
<!-- ATTRIBUTE VALUES -->
<div class="attribute-values text-left">
    <h3>Attribute Values <small>Space and Kapp Levels Only</small></h3>
    <table class="table table-hover">
        <thead>
            <tr>
                <th>Level</th>
                <th>Name</th>
                <th width="40%">Values</th>
                <th width="10%">Required</th>
                <th width="14%">Allows Multiple</th>
            </tr>
        </thead>
        <tbody>
            <tr class="empty-state-message">
                <td colspan="6"><i>No space or kapp attributes defined.</i></td>
            </tr>
            <!-- SPACE ATTRIBUTE VALUES -->
            <c:forEach items="${SetupHelper.getSpaceAttributeDefinitions()}" var="attributeDefinition">
                <tr data-name="${attributeDefinition.name}" data-level="space"
                        class="space-attribute ${attributeDefinition.isDefinitionExists() ? 'success' : 'danger'}">
                    <td>Space</td>
                    <td>${attributeDefinition.name}</td>
                    <td class="space-attribute-values">
                        <c:if test="${attributeDefinition.hasAttributeValues()}">
                            <c:forEach items="${attributeDefinition.getAttribute().getValues()}" var="attributeValue">
                                <div class="input-group input-group-sm attribute-value">
                                    <span class="input-group-addon label-success"><span class="fa fa-check"></span> <span class="status">Found</span></span>
                                    <input type="text" class="form-control" placeholder="Attribute Value" value="${attributeValue}">
                                    <span class="input-group-btn">
                                        <button class="btn btn-sm btn-danger delete-value" type="button"><span class="fa fa-times"></span></button>
                                    </span>
                                </div>
                            </c:forEach>
                        </c:if>
                        <c:forEach items="${attributeDefinition.getMissingDefaultValues()}" var="attributeValue">
                            <div class="input-group input-group-sm attribute-value">
                                <span class="input-group-addon label-warning"><span class="fa fa-times"></span> <span class="status">New</span></span>
                                <input type="text" class="form-control" placeholder="Attribute Value" value="${attributeValue}">
                                <span class="input-group-btn">
                                    <button class="btn btn-sm btn-danger delete-value" type="button"><span class="fa fa-times"></span></button>
                                </span>
                            </div>
                        </c:forEach>
                        <div class="input-group input-group-sm ${attributeDefinition.isAllowsMultiple() ? '' : 'single-add-restriction'}">
                            <input type="text" class="form-control" placeholder="Add Attribute Value" value="${attributeValue}">
                            <span class="input-group-btn">
                                <button class="btn btn-sm btn-success add-value" type="button"><span class="fa fa-plus"></span></button>
                            </span>
                        </div>
                    </td>
                    <td>${attributeDefinition.isRequired() ? '<b class="text-danger">Required</b>' : 'Optional'}</td>
                    <td>${attributeDefinition.isAllowsMultiple() ? 'Yes' : 'No'}</td>
                </tr>
            </c:forEach>
            <!-- KAPP ATTRIBUTE VALUES -->
            <c:forEach items="${SetupHelper.getKappAttributeDefinitions()}" var="attributeDefinition">
                <tr data-name="${attributeDefinition.name}" data-level="kapp" 
                        class="${attributeDefinition.isDefinitionExists() ? 'success' : 'danger'}">
                    <td>Kapp</td>
                    <td>${attributeDefinition.name}</td>
                    <td class="kapp-attribute-values">
                        <c:if test="${attributeDefinition.hasAttributeValues()}">
                            <c:forEach items="${attributeDefinition.getAttribute().getValues()}" var="attributeValue">
                                <div class="input-group input-group-sm attribute-value">
                                    <span class="input-group-addon label-success"><span class="fa fa-check"></span> <span class="status">Found</span></span>
                                    <input type="text" class="form-control" placeholder="Attribute Value" value="${attributeValue}">
                                    <span class="input-group-btn">
                                        <button class="btn btn-sm btn-danger delete-value" type="button"><span class="fa fa-times"></span></button>
                                    </span>
                                </div>
                            </c:forEach>
                        </c:if>
                        <c:forEach items="${attributeDefinition.getMissingDefaultValues()}" var="attributeValue">
                            <div class="input-group input-group-sm attribute-value">
                                <span class="input-group-addon label-warning"><span class="fa fa-times"></span> <span class="status">New</span></span>
                                <input type="text" class="form-control" placeholder="Attribute Value" value="${attributeValue}">
                                <span class="input-group-btn">
                                    <button class="btn btn-sm btn-danger delete-value" type="button"><span class="fa fa-times"></span></button>
                                </span>
                            </div>
                        </c:forEach>
                        <div class="input-group input-group-sm ${attributeDefinition.isAllowsMultiple() ? '' : 'single-add-restriction'}">
                            <input type="text" class="form-control" placeholder="Add Attribute Value" value="${attributeValue}">
                            <span class="input-group-btn">
                                <button class="btn btn-sm btn-success add-value" type="button"><span class="fa fa-plus"></span></button>
                            </span>
                        </div>
                    </td>
                    <td>${attributeDefinition.isRequired() ? '<b>Required</b>' : 'Optional'}</td>
                    <td>${attributeDefinition.isAllowsMultiple() ? 'Yes' : 'No'}</td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</div>

<c:import url="${bundle.path}/setup/wizard/navigation.jsp" charEncoding="UTF-8"/>