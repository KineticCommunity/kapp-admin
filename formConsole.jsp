<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="bundle/initialization.jspf" %>

<bundle:layout page="layouts/layout.jsp">
    <!-- Sets title and imports js and css specific to this console. -->
    <bundle:variable name="head">
        <app:formHeadContent/>
    </bundle:variable>
    
    <!-- BREADCRUMBS START HERE. Remove if not needed. ------------------------------------------->
    <bundle:variable name="breadcrumb">
        <c:forEach items="${AdminHelper.getFormDefinedConsoleBreadcrumbs(form)}" var="breadcrumb" varStatus="status">
            <c:choose>
                <c:when test="${!status.last}">
                    <li><a href="${breadcrumb.href}">${breadcrumb.name}</a></li>
                </c:when>
                <c:otherwise>
                    <li class="active">${breadcrumb.name}</li>
                </c:otherwise>
            </c:choose>
        </c:forEach>
    </bundle:variable>
    <!-- BREADCRUMBS END HERE. ------------------------------------------------------------------->
    
    <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
    <div class="page-header">
        <h2>
            ${text.defaultIfBlank(form.getAttributeValue('Console Header Name'), form.name)}
            <div class="pull-right console-header-buttons">
                <script>
                    if (typeof bundle.admin.populateAdminFormConsoleHeaderButtons === "function") {
                        document.write(bundle.admin.populateAdminFormConsoleHeaderButtons.call());
                    }
                </script>
            </div>
        </h2>
    </div>
    
    <app:bodyContent/>

    <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
    
    <!-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -------------------------------->
    <bundle:variable name="aside">
        <h3>${text.defaultIfBlank(form.getAttributeValue('Console Header Name'), form.name)}</h3>
        <p>${form.description}</p>
        <script>
            if (typeof bundle.admin.populateAdminFormConsoleAside === "function") {
                document.write("<hr class=\"border-color-white\" />");
                document.write(bundle.admin.populateAdminFormConsoleAside.call());
            }
        </script>
    </bundle:variable>
    <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->

</bundle:layout>
