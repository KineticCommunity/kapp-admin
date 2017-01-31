<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>

<div class="attribute m-b-2">
    <label class="control-label">${i18n.translate(thisAttribute.name)}</label>
    <span id="helpBlock-${thisAttribute.name}" class="help-block">${thisAttribute.description}</span>   
    <input name="${thisAttribute.name}" style="display:none;" class="attributeValue form-control" value="${currentObj.getAttributeValue(thisAttribute.name)}">

    <!-- Build Up Radio Button's to Drive Approval Type -->
    <div class="approvalRadios">
        <label class="radio-inline">
            <input type="radio" data-type="none" name="approvalType">None
        </label>

        <label class="radio-inline">
            <input type="radio" data-type="manager" name="approvalType">Manager
        </label>

        <label class="radio-inline">
            <input type="radio" data-type="team" name="approvalType">Team
        </label>

        <label class="radio-inline">
            <input type="radio" data-type="individual" name="approvalType">Individual
        </label>
    </div>

    <!-- Build Up Selection Dropdowns for Teams and Individuals -->
    <div>
        <div id="approverTeams" style="display:none;">
            <span class="help-block">Select a Team to send Approvals to</span>
            <select class="approvalSelector form-control">
                <option/>
                <c:forEach items="${space.teams}" var="team">
                    <c:set var="selected" value=""/>
                    <c:if test="${team.name eq currentObj.getAttributeValue(thisAttribute.name)}">
                        <c:set var="selected" value="selected"/>
                    </c:if>
                    <option ${selected} value="${team.name}">${team.name}</option>
                </c:forEach>
            </select>
        </div>
        <div id="approverIndividuals" style="display:none;">
            <span class="help-block">Select a User to send Approvals to</span>
            <select class="approvalSelector form-control">
                <option/>
                <c:forEach items="${space.users}" var="user">
                    <c:set var="selected" value=""/>
                    <c:if test="${user.username eq currentObj.getAttributeValue(thisAttribute.name)}">
                        <c:set var="selected" value="selected"/>
                    </c:if>
                    <option ${selected} value="${user.username}">${user.displayName}</option>
                </c:forEach>
            </select>
        </div>
    </div>
</div>