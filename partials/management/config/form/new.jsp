<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../../../bundle/initialization.jspf" %>
<c:set var="currentKapp" value="${space.getKapp(param.kapp)}" />
<c:set var="currentForm" value="${currentKapp.getForm(param.form)}" />

<c:choose>
    <c:when test="${empty currentKapp}">
        <div class="alert alert-danger">Could not find the Kapp. Please contact an administrator.</div>
    </c:when>
    <c:when test="${empty currentForm && empty currentKapp.getFormsByType('Template')}">
        <div class="alert alert-danger">In order to create a new form, you must clone a Template form, but the ${currentKapp.name} Kapp doesn't contain any forms of type Template.</div>
    </c:when>
    <c:otherwise>
        <c:choose>
            <c:when test="${not empty currentForm}">
                <div data-clone-form="${currentForm.slug}">
                    <label class="field-label">
                        <span id="label-clone-form">${i18n.translate('Form to Clone')}</span>
                    </label>
                    <input type="text" aria-labelledby="label-clone-form"
                           name="form-name" class="form-control" disabled value="${currentForm.name}">
                </div>
            </c:when>
            <c:otherwise>
                <div data-clone-form>
                    <label class="field-label required" data-error-message="You must select a template to clone.">
                        <span id="label-clone-form">${i18n.translate('Template to Clone')}</span>
                    </label>
                    <select aria-labelledby="label-clone-form" name="form-status">
                        <option />
                        <c:forEach items="${currentKapp.getFormsByType('Template')}" var="template">
                            <option value="${template.slug}">${template.name}</option>
                        </c:forEach>
                    </select>
                </div>
            </c:otherwise>
        </c:choose>
        
        <div data-property="name">
            <label class="field-label required" data-error-message="Name is required.">
                <span id="label-form-name">${i18n.translate('Name')}</span>
            </label>
            <input type="text" aria-labelledby="label-form-name" 
                   name="form-name" class="form-control">
        </div>
        
        <div data-property="slug">
            <label class="field-label required" data-error-message="Slug is required.">
                <span id="label-form-slug">${i18n.translate('Slug')}</span>
            </label>
            <input type="text" aria-labelledby="label-form-slug" 
                   name="form-slug" class="form-control">
        </div>
        
        <div data-property="description">
            <label class="field-label">
                <span id="label-form-description">${i18n.translate('Description')}</span>
            </label>
            <textarea aria-labelledby="label-form-description" 
                      name="form-description" class="form-control"></textarea>
        </div>
        
        <div data-property="status">
            <label class="field-label required" data-error-message="Status is required.">
                <span id="label-form-status">${i18n.translate('Status')}</span>
            </label>
            <c:set var="selectedStatus" value="${not empty currentForm ? currentForm.status : 'Active'}" />
            <select aria-labelledby="label-form-status" name="form-status">
                <option value="New" ${text.equals('New', selectedStatus) ? 'selected' : ''}>New</option>
                <option value="Active" ${text.equals('Active', selectedStatus) ? 'selected' : ''}>Active</option>
                <option value="Inactive" ${text.equals('Inactive', selectedStatus) ? 'selected' : ''}>Inactive</option>
                <option value="Delete" ${text.equals('Delete', selectedStatus) ? 'selected' : ''}>Delete</option>
            </select>
        </div>
        
        <div data-property="type">
            <label class="field-label required" data-error-message="Type is required.">
                <span id="label-form-type">${i18n.translate('Type')}</span>
            </label>
            <c:set var="selectedType" value="${not empty currentForm && not empty currentForm.type ? currentForm.type.name : 'Service'}" />
            <select aria-labelledby="label-form-type" name="form-status">
                <c:forEach items="${currentKapp.formTypes}" var="option">
                    <option value="${option.name}" ${text.equals(option.name, selectedType) ? 'selected' : ''}>${option.name}</option>
                </c:forEach>
            </select>
        </div>
        
        <div data-attribute="Owning Team">
            <label class="field-label required" data-error-message="You must select at least one owning team.">
                <span id="label-owning-team">${i18n.translate('Owning Team')}</span>
            </label>
            <c:if test="${dataObject.get('_default') != null}">
                <c:forEach items="${dataObject}" var="option">
                    <c:if test="${empty selectedRadio && text.equals(option.value, attributeObject.value)}">
                        <c:set var="selectedRadio" value="${option.value}" />
                    </c:if>
                </c:forEach>
                <c:if test="${empty selectedRadio}">
                    <c:set var="selectedRadio" value="${dataObject.get('_default')}" />
                </c:if>
            </c:if>
            <c:set var="userTeams" value="${identity.spaceAdmin ? TeamsHelper.getTeams() : TeamsHelper.getUserTeams(identity.user)}" />
            <select multiple aria-labelledby="label-owning-team" name="owning-team">
                <c:forEach items="${userTeams}" var="team">
                    <option value="${team.name}" ${fn:length(userTeams) == 1 || (not empty currentForm && currentForm.hasAttributeValue('Owning Team', team.name)) ? 'selected' : ''}>${team.name}</option>
                </c:forEach>
            </select>
        </div>
    </c:otherwise>
</c:choose>