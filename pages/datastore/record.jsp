<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<c:set var="currentKapp" value="${space.getKapp(param.kapp)}" scope="request" />
<c:set var="currentStore" value="${kapp.getForm(param.store)}" scope="request" />

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <!-- Sets title and imports js and css specific to this console. -->
    <bundle:variable name="head">
        <c:import url="${bundle.path}/partials/${form.slug}/head.jsp" charEncoding="UTF-8"/>
    </bundle:variable>
    
    <c:set var="currentKapp" value="${space.getKapp(param.kapp)}" scope="request" />
    <c:set var="currentStore" value="${kapp.getForm(param.store)}" scope="request" />

    <!-- Show page content only if Kapp exists. Otherwise redirect to home page. -->
    <c:choose>
        <c:when test="${empty currentKapp}">
            <c:redirect url="${bundle.kappPath}"/>
        </c:when>
        <c:when test="${!identity.spaceAdmin}">
            <c:import url="${bundle.path}/partials/${form.slug}/adminError.jsp" charEncoding="UTF-8"/>
        </c:when>
        <c:otherwise>
            
            <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
            
            <ol class="breadcrumb">
                <li><a href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}">${form.name}</a></li>
                <li><a href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=datastore/store&store=${currentStore.slug}" class="return-to-store">${currentStore.name}</a></li>
                <li class="active ng-binding">${empty param.id ? 'New' : 'Edit'}</li>
            </ol>
            
            <div class="page-header">
                <h3>${empty param.id ? 'New ' : 'Edit '}${currentStore.name} Record</h3>
            </div>
            
            <div class="row">
                <div class="col-xs-12 store-container" data-submission-id="${param.id}">
                    <script>
                        $(function(){
                            if ($('div.store-container').data('submission-id')){
                                K.load({
                                    path: "${bundle.spaceLocation}/submissions/${param.id}", 
                                    container: $('div.store-container')  
                                });
                            }
                            else {
                                K.load({
                                    path: "${bundle.spaceLocation}/${kapp.slug}/${currentStore.slug}", 
                                    container: $('div.store-container')  
                                });                                
                            }
                        });
                    </script>
                </div>
            </div>
            
            
            <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
    
            <!-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -------------------------------->
            <bundle:variable name="aside">
                <h3>TITLE</h3>
                <p>
                    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor 
                    incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud 
                    exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute 
                    irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla 
                    pariatur.
                </p>
            </bundle:variable>
            <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
            
        </c:otherwise>
    </c:choose>
</bundle:layout>