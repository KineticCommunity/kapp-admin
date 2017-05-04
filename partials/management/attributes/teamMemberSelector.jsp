<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../../bundle/initialization.jspf" %>

<c:set var="teamNameToSlugMap">
    <json:object>
        <c:forEach var="o" items="${TeamsHelper.teams}">
            <json:property name="${o.name}" value="${o.slug}" />
        </c:forEach>
    </json:object>
</c:set>

<div data-attribute="${definitionObject.name}" data-team-attribute-name="${dataObject.teamAttributeName}" data-init-value="${attributeObject.value}">
    <label class="field-label">
        <span id="label-${definitionObject.name}">${i18n.translate(param.label)}</span>
        <i class="small" id="description-${definitionObject.name}">${i18n.translate(definitionObject.description)}</i>
    </label>
    <select aria-describedby="description-${definitionObject.name}" aria-labelledby="label-${definitionObject.name}" 
            class="form-control" name="users-${definitionObject.name}">
    </select>
    <div class="hide team-map-json">${teamNameToSlugMap}</div>
</div>

<script>
    $(function(){
        initTeamMemberSelector($("div[data-attribute='${definitionObject.name}']"));
    });
    function initTeamMemberSelector(container){
        var teamAttributeName = container.data("team-attribute-name");
        var teamAttributeContainer = container.prevAll("[data-attribute='" + teamAttributeName + "']").first();
        var teamAttributeSelect = teamAttributeContainer.find("select");
        var teamNameToSlugMap = JSON.parse(container.find("div.team-map-json").text() || "{}");
        if (teamAttributeSelect.length){
            teamAttributeSelect.on("change", function(e){
                buildTeamMemberSelector(container, $(this), teamAttributeName, teamNameToSlugMap);
            });
            buildTeamMemberSelector(container, teamAttributeSelect, teamAttributeName, teamNameToSlugMap, container.data("init-value"));
        }
        else {
            container.empty().append(
                $("<span>", {class: "text-danger"}).append(
                    $("<span>", {class: "fa fa-exclamation-triangle"}), 
                    $("<span>").text(
                        "The team member selector for the attribute <strong>" + container.data("attribute") + "</strong> " 
                        + "could not be loaded, because the corresponding team selector for the attribute " 
                        + "<strong>" + container.data("team-attribute-name") + "</strong> could not be found."
                    )
                )
            );
        }
    };
    function buildTeamMemberSelector(container, teamAttributeSelect, teamAttributeName, teamNameToSlugMap, selectedValue){
        var selectedTeamSlug = teamNameToSlugMap[teamAttributeSelect.val()];
        if (selectedTeamSlug){
            $.ajax({
                method: "get",
                url: encodeURI(bundle.apiLocation() + "/teams/" + selectedTeamSlug + "?include=memberships.user"),
                dataType: "json",
                contentType: "application/json",
                success: function(data){
                    var select = container.find("select").empty();
                    if (data.team.memberships && data.team.memberships.length > 0){
                        select.prepend($("<option>"));
                        $.each(data.team.memberships, function(i, membership){
                            var option = $("<option>", {value: membership.user.username}).text(membership.user.displayName || membership.user.username);
                            if (selectedValue && membership.user.username === selectedValue){
                                option.prop("selected", true);
                            }
                            select.append(option);
                        });
                    }
                    else {
                        select.append($("<option>", {disabled: true, selected: true}).text("The " + teamAttributeSelect.val() + " team does not have any members."));
                    }
                    container.removeClass("hide");
                },
                error: function(jqXHR, textStatus, errorThrown){
                    var select = container.find("select").empty();
                    select.append($("<option>", {disabled: true, selected: true}).text("There was an error retrieving the " + teamAttributeSelect.val() + " team's members."));
                    container.removeClass("hide");
                }
            });
        }
        else {
            container.find("select").empty();
            container.addClass("hide");
        }
    };
</script>