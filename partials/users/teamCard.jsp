<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../bundle/initialization.jspf" %>

<div class="card-wrapper col-xs-12 col-sm-6 col-md-4">
    <div class="team-card" style="border-top-color:${teamObj.color};"
         data-team-slug="${teamObj.slug}"  >
        <div class="team-icon">
            <span class="fa-stack">
              <span class="fa fa-circle fa-stack-2x" style="color:${teamObj.color};"></span>
              <span class="fa ${teamObj.icon} fa-stack-1x"></span>
            </span>
        </div>
        <div class="parent-path">
            <a href="${bundle.kappLocation}?page=team&team=${teamObj.parent.slug}">${teamObj.parent.name}</a>
        </div>
        <div class="team-name" style="color:${teamObj.color};">
            ${teamObj.localName}
        </div>
        <div class="team-members">
            <c:forEach var="teamMember" items="${teamObj.users}" end="15">
                <a href="${bundle.getKappLocation(text.defaultIfBlank(adminKapp.slug, 'admin'))}?page=users/user&username=${text.escapeUrlParameter(teamMember.username)}" 
                   title="${text.defaultIfBlank(teamMember.username, teamMember.email)}">
                    ${GravatarHelper.get(teamMember.email, 24)}
                </a>
            </c:forEach>
        </div>
    </div>
</div>