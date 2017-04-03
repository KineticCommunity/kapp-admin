<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../../../bundle/initialization.jspf" %>

<c:set var="currentKapp" value="${space.getKapp(param.kapp)}" />
<c:set var="currentForm" value="${currentKapp.getForm(param.form)}" />

<div data-categorizations class="m-t-1">
    <c:set var="categoriesMap">
        <json:object>
            <c:forEach items="${currentForm.categorizations}" var="categorization">
                <json:property name="${categorization.category.slug}" value="${true}" />
            </c:forEach>
        </json:object>
    </c:set>
    <c:set var="categories" value="${json.parse(categoriesMap)}" />
    <c:forEach items="${currentKapp.categories}" var="category">
        <span class="checkbox-label display-block">
            <input type="checkbox" id="categorization-${category.slug}" name="form-categorizations" value="${category.slug}"
                   ${categories[category.slug] ? 'checked' : ''}>
            <label class="label label-default" for="categorization-${category.slug}">
                <span>${category.name}</span>
            </label>
        </span>
    </c:forEach>
</div>

<div class="m-y-2 text-right">
    <button data-save-button class="btn btn-success">
        <span class="fa fa-check fa-fw"></span>
        <span>Update Categories</span>
    </button>
    <button data-reset-button class="btn btn-link">
        <span>Reset</span>
    </button>
</div>