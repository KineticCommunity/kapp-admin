<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<c:set var="currentKapp" value="${space.getKapp(param.kapp)}" scope="request" />
<c:set var="currentStore" value="${kapp.getForm(param.store)}" scope="request" />

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <!-- Sets title and imports js and css specific to this console. -->
    <bundle:variable name="head">
        <c:import url="${bundle.path}/partials/${form.slug}/head.jsp" charEncoding="UTF-8"/>
    </bundle:variable>
    
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
                <li class="active ng-binding">${not empty param.id ? 'Edit' : empty param.clone ? 'New' : 'Clone'}</li>
            </ol>
            
            <div class="page-header">
                <h3>${not empty param.id ? 'Edit ' : empty param.clone ? 'New ' : 'Clone '}${currentStore.name} Record</h3>
            </div>
            
            <div class="row">
                <div class="col-xs-12 datastore-record-container" data-datastore-slug="${currentStore.slug}"
                        data-record-id="${param.id}" data-clone-id="${param.clone}">
                    <script>
                        $(function(){
                            if ("${param.id}"){
                                K.load({
                                    path: "${bundle.spaceLocation}/submissions/${param.id}", 
                                    container: $('div.datastore-record-container')
                                });
                            }
                            else if ("${param.clone}"){
                                $.ajax({
                                    mathod: "GET",
                                    url: "${bundle.apiLocation}/submissions/${param.clone}?include=values,form",
                                    dataType: "json",
                                    contentType: "application/json",
                                    success: function(clone, textStatus, jqXHR){
                                        K.load({
                                            path: "${bundle.kappLocation}/${currentStore.slug}", 
                                            container: $('div.datastore-record-container'),
                                            loaded: function(form){
                                                console.log("clone", clone);
                                                console.log("form", form);
                                                if (clone.submission.form.name === form.name){
                                                    _.each(clone.submission.values, function(value, key){
                                                        if (form.fields[key]){
                                                            form.fields[key].value(value);
                                                        }
                                                    });
                                                }
                                            }
                                        }); 
                                    },
                                    error: function(jqXHR, textStatus, errorThrown){
                                        console.log("ERROR"); // TODO
                                    }
                                });
                            }
                            else {
                                K.load({
                                    path: "${bundle.kappLocation}/${currentStore.slug}", 
                                    container: $('div.datastore-record-container')
                                });                                
                            }
                        });
                    </script>
                </div>
            </div>
            
            
            <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
    
            <!-- RIGHT SIDEBAR CONTENT STARTS HERE. Remove if not needed. -------------------------------->
            <bundle:variable name="aside">
                <h3>${currentStore.name}</h3>
                <p>
                    ${currentStore.description}
                </p>
            </bundle:variable>
            <!-- RIGHT SIDEBAR CONTENT ENDS HERE. -------------------------------------------------------->
            
        </c:otherwise>
    </c:choose>
</bundle:layout>