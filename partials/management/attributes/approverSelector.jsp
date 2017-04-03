<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../../bundle/initialization.jspf" %>

<%-- Create radio input options to show --%>
<c:set var="radioOptions">
    <json:object>
        <json:property name="None" value="None" />
        <json:property name="Manager" value="Manager" />
        <json:property name="Team" value="Team" />
        <json:property name="Individual" value="Individual" />
    </json:object>
</c:set>
<%-- Set selectedRadio to 'Manager' if the stored value is 'Manager' --%>
<c:if test="${text.equals(attributeObject.value, 'Manager')}">
    <c:set var="selectedRadio" value="Manager" />
</c:if>
<%-- Build list of teams as options --%>
<c:set var="teamOptions">
    <json:object>
        <c:forEach var="o" items="${space.teams}">
            <c:if test="${not text.startsWith(o.name, 'Role::')}">
                <json:property name="${o.name}" value="${o.name}" />
                <%-- Set selectedRadio to 'Team' if the stored value is matches a team --%>
                <c:if test="${empty selectedRadio && text.equals(attributeObject.value, o.name)}">
                    <c:set var="selectedRadio" value="Team" />
                </c:if>
            </c:if>
        </c:forEach>
    </json:object>
</c:set>
<%-- Build list of users as options --%>
<c:set var="userOptions">
    <json:object>
        <c:forEach var="o" items="${space.users}">
            <json:property name="${text.defaultIfBlank(o.displayName, o.username)}" value="${o.username}" />
            <%-- Set selectedRadio to 'Individual' if the stored value is matches a user --%>
            <c:if test="${empty selectedRadio && text.equals(attributeObject.value, o.username)}">
                <c:set var="selectedRadio" value="Individual" />
            </c:if>
        </c:forEach>
    </json:object>
</c:set>
<%-- Set selectedRadio to 'None' if the stored value wasn't matched above --%>
<c:if test="${empty selectedRadio}">
    <c:set var="selectedRadio" value="None" />
</c:if>

<div data-attribute="${definitionObject.name}">
    <label class="field-label">
        <span id="label-${definitionObject.name}">${i18n.translate(param.label)}</span>
        <i class="small" id="description-${definitionObject.name}">${i18n.translate(definitionObject.description)}</i>
    </label>
    
    <%-- Hidden input that will be used to set and save the actual attribute value --%>
    <input type="text" aria-describedby="description-${definitionObject.name}" aria-labelledby="label-${definitionObject.name}" 
           name="${definitionObject.name}" class="form-control hide" value="${attributeObject.value}">
           
    <%-- Radio inputs to select approver type --%>
    <c:forEach items="${json.parse(radioOptions)}" var="option">
        <span class="radio-label">
            <input type="radio" aria-describedby="description-${definitionObject.name}" aria-labelledby="label-${definitionObject.name}" 
                   id="radio-${definitionObject.name}-${option.value}" name="radio-${definitionObject.name}" value="${option.value}"
                   class="ignore-value" ${text.equals(option.value, selectedRadio) ? 'checked' : ''}>
            <label class="label label-default" for="radio-${definitionObject.name}-${option.value}">
                <span>${option.key}</span>
            </label>
        </span>
    </c:forEach>
    
    <%-- Team selector for when Approver is a Team --%>
    <div class="input-group ${text.equals(selectedRadio, 'Team') ? '' : 'hide'}">
        <span class="input-group-addon">Team</span>
        <select aria-describedby="description-${definitionObject.name}" aria-labelledby="label-${definitionObject.name}" 
                class="ignore-value form-control" name="teams-${definitionObject.name}" value="${attributeObject.value}">
            <option disabled>Select a team to which approvals will be sent</option>
            <c:forEach items="${json.parse(teamOptions)}" var="option">
                <option value="${option.value}" ${text.equals(option.value, attributeObject.value) ? 'selected' : ''}>${option.key}</option>
            </c:forEach>
        </select>
    </div>
    
    <%-- User selector for when Approver is an Individual --%>
    <div class="input-group ${text.equals(selectedRadio, 'Individual') ? '' : 'hide'}">
        <span class="input-group-addon">User</span>
        <select aria-describedby="description-${definitionObject.name}" aria-labelledby="label-${definitionObject.name}" 
                class="ignore-value form-control" name="users-${definitionObject.name}" value="${attributeObject.value}">
            <option disabled>Select a user to whom approvals will be sent</option>
            <c:forEach items="${json.parse(userOptions)}" var="option">
                <option value="${option.value}" ${text.equals(option.value, attributeObject.value) ? 'selected' : ''}>${option.key}</option>
            </c:forEach>
        </select>
    </div>
</div>

<%-- Events for setting the actual value to be saved and for showing/hiding appropriate controls --%>
<script>
    $("div[data-attribute='${definitionObject.name}']").on("change", "input[type=radio]", function(e){
        var container = $(this).closest("div[data-attribute]");
        var input = container.find("input[type=text][name='${definitionObject.name}']");
        input.val($(this).val());
        var teams = container.find("select[name='teams-${definitionObject.name}']");
        var users = container.find("select[name='users-${definitionObject.name}']");
        if ($(this).val() === "Team"){
            teams.val("").parent().removeClass("hide");
            teams.find("option:first-child").prop("selected", true);
            users.val("").parent().addClass("hide");
        }
        else if ($(this).val() === "Individual"){
            users.val("").parent().removeClass("hide");
            users.find("option:first-child").prop("selected", true);
            teams.val("").parent().addClass("hide");
        }
        else {
            teams.val("").parent().addClass("hide");
            users.val("").parent().addClass("hide");
        }
    }).on("change", "select", function(e){
        var container = $(this).closest("div[data-attribute]");
        var input = container.find("input[type=text][name='${definitionObject.name}']");
        input.val($(this).val());
    });
</script>