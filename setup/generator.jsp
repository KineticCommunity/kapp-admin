<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../bundle/initialization.jspf" %>

<bundle:layout page="${bundle.path}/layouts/layout.jsp">
    <!-- Sets imports js and css specific to the setup pages. -->
    <bundle:variable name="head">
        <bundle:stylepack>
            <bundle:style src="${bundle.location}/setup/setup.css"/>
        </bundle:stylepack>
        <bundle:scriptpack>
            <bundle:script src="${bundle.location}/setup/setup.js" />
        </bundle:scriptpack>
        <script>
        
            $(function(){
                if ($("div.generator").length){
                    $("div.generator div.panel").on("click", "div.panel-heading button", function(e){
                        $(this).closest("div.panel").slideUp(function(){
                            $(this).remove()
                            generateJson();
                        });
                    }).on("change", "input", function(e){
                        generateJson();
                    });
                    
                    $("div.generator textarea.generated-json").on("focus", function(e){
                        $(this).select();
                    });
                    
                    generateJson();
                }
            });
            
            function generateJson(){
                var json = new Object();
                
                $("div.generator div.json-container").each(function(i,e){
                    var containerName = $(e).data("container");
                    $(e).children().each(function(index, object){
                        json[containerName] = json[containerName] || new Array();
                        json[containerName].push(processItem($(object)));
                    });
                });
                
                if ($("div.generator input.generated-json-minified").prop("checked")){
                    $("div.generator textarea.generated-json").val(JSON.stringify(json));
                }
                else {
                    $("div.generator textarea.generated-json").val(JSON.stringify(json, null, 4));
                }
            }
            
            function processItem(item){
                if (item.is("div.object")){
                    var object = item.is("div.json") ? item.data("json") : new Object();
                    item.children().each(function(i, child){
                        object[$(child).attr("name")] = processItem($(child));
                    });
                    return object;
                }
                else if (item.is("div.array")){
                    var array = item.is("div.json") ? item.data("json") : new Array();
                    item.children().each(function(i, child){
                        var childResult = processItem($(child));
                        if (childResult != null){
                            array.push(childResult);
                        }
                    });
                    return array;
                }
                else if (item.is("span")){
                    if (item.find("input[type='checkbox']").length){
                        return item.find("input[type='checkbox']").prop("checked");
                    }
                    else if (item.find("input[type='text']").length){
                        var value = item.find("input[type='text']").val().trim(); 
                        return value.length > 0 ? value : null;
                    }
                    else {
                        var text = item.text().trim(); 
                        return text.length > 0 ? text : null;
                    }
                }
            }
        
        </script>
    </bundle:variable>
    <div class="generator">
        <h2 class="text-center">
            ${kapp.name} Kapp Setup Json Generator
        </h2>
        <c:choose>
            <c:when test="${!identity.spaceAdmin}">
                <div class="alert alert-danger">
                    <h4>You do not have access to this page.</h4>
                </div>
            </c:when>
            <c:otherwise>
                
                <div class="no-data">
                    <p>
                        You may remove any components you do not want by clicking the remove button.
                    </p>
                    <p>
                        You may modify certain fields such as attribute values and bridge queries. 
                        In these editable fields, you may use the following Java variables which will be evaluated when the wizard runs the setup.json file. 
                        <p>
                            {{kapp.name}} <br />
                            {{kapp.slug}} <br />
                            {{adminKapp.name}} <br />
                            {{adminKapp.slug}}
                        </p>
                    </p>
                </div>
            
                <c:forEach var="item" items="${space.spaceAttributeDefinitions}">
                    <div class="panel panel-primary">
                        <div class="panel-heading">Space Attribute Definition <button class="btn btn-xs btn-danger pull-right"><span class="fa fa-times"></span> Remove</button></div>
                        <div class="panel-body json-container" data-container="spaceAttributeDefinitions">
                            <div class="object">
                                <span name="name">${item.name}</span>
                                <span name="allowsMultiple"><input type="checkbox" ${item.allowsMultiple ? 'checked' : ''} disabled/></span>
                                <span name="required"><input type="checkbox" /></span>
                                <span name="description"><input type="text" value="" /></span>
                                <div class="array" name="values"><c:forEach var="val" items="${space.getAttributeValues(item.name)}"><span><input type="text" value="${Text.escape(val)}"/></span></c:forEach></div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
                
                <c:forEach var="item" items="${kapp.kappAttributeDefinitions}">
                    <div class="panel panel-primary">
                        <div class="panel-heading">Kapp Attribute Definition <button class="btn btn-xs btn-danger pull-right"><span class="fa fa-times"></span> Remove</button></div>
                        <div class="panel-body json-container" data-container="kappAttributeDefinitions">
                            <div class="object">
                                <span name="name">${item.name}</span>
                                <span name="allowsMultiple"><input type="checkbox" ${item.allowsMultiple ? 'checked' : ''} disabled/></span>
                                <span name="required"><input type="checkbox" /></span>
                                <span name="description"><input type="text" value="" /></span>
                                <div class="array" name="values"><c:forEach var="val" items="${kapp.getAttributeValues(item.name)}"><span><input type="text" value="${Text.escape(val)}"/></span></c:forEach></div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
                
                <c:forEach var="item" items="${kapp.formAttributeDefinitions}">
                    <div class="panel panel-primary">
                        <div class="panel-heading">Form Attribute Definition <button class="btn btn-xs btn-danger pull-right"><span class="fa fa-times"></span> Remove</button></div>
                        <div class="panel-body json-container" data-container="formAttributeDefinitions">
                            <div class="object">
                                <span name="name">${item.name}</span>
                                <span name="allowsMultiple"><input type="checkbox" ${item.allowsMultiple ? 'checked' : ''} disabled/></span>
                                <span name="required"><input type="checkbox" /></span>
                                <span name="description"><input type="text" value="" /></span>
                            </div>
                        </div>
                    </div>
                </c:forEach>
                
                <c:forEach var="item" items="${kapp.categoryAttributeDefinitions}">
                    <div class="panel panel-primary">
                        <div class="panel-heading">Category Attribute Definition <button class="btn btn-xs btn-danger pull-right"><span class="fa fa-times"></span> Remove</button></div>
                        <div class="panel-body json-container" data-container="categoryAttributeDefinitions">
                            <div class="object">
                                <span name="name">${item.name}</span>
                                <span name="allowsMultiple"><input type="checkbox" ${item.allowsMultiple ? 'checked' : ''} disabled/></span>
                                <span name="required"><input type="checkbox" /></span>
                                <span name="description"><input type="text" value="" /></span>
                            </div>
                        </div>
                    </div>
                </c:forEach>
                
                <c:forEach var="item" items="${space.userAttributeDefinitions}">
                    <div class="panel panel-primary">
                        <div class="panel-heading">User Attribute Definition <button class="btn btn-xs btn-danger pull-right"><span class="fa fa-times"></span> Remove</button></div>
                        <div class="panel-body json-container" data-container="userAttributeDefinitions">
                            <div class="object">
                                <span name="name">${item.name}</span>
                                <span name="allowsMultiple"><input type="checkbox" ${item.allowsMultiple ? 'checked' : ''} disabled/></span>
                                <span name="required"><input type="checkbox" /></span>
                                <span name="description"><input type="text" value="" /></span>
                            </div>
                        </div>
                    </div>
                </c:forEach>
                
                <c:forEach var="item" items="${space.bridges}">
                    <div class="panel panel-primary">
                        <div class="panel-heading">Bridge <button class="btn btn-xs btn-danger pull-right"><span class="fa fa-times"></span> Remove</button></div>
                        <div class="panel-body json-container" data-container="bridges">
                            <div class="object">
                                <span name="name">${item.name}</span>
                                <span name="status">${item.status}</span>
                                <span name="url"><input type="text" value="${Text.escape(item.url)}" /></span>
                            </div>
                        </div>
                    </div>
                </c:forEach>
                
                <c:forEach var="model" items="${space.bridgeModels}">
                    <div class="panel panel-primary">
                        <div class="panel-heading">Bridge Model with Mappings <button class="btn btn-xs btn-danger pull-right"><span class="fa fa-times"></span> Remove</button></div>
                        <div class="panel-body json-container" data-container="bridgeModels">
                            <div class="object">
                                <span name="name">${model.name}</span>
                                <span name="status">${model.status}</span>
                                <span name="activeMappingName">${model.activeMappingName}</span>
                                <div class="array" name="attributes">
                                    <c:forEach var="attribute" items="${model.attributes}">
                                        <div class="object">
                                            <span name="name">${attribute.name}</span>
                                        </div>
                                    </c:forEach>
                                </div>
                                <div class="array" name="qualifications">
                                    <c:forEach var="qualification" items="${model.qualifications}">
                                        <div class="object">
                                            <span name="name">${qualification.name}</span>
                                            <span name="resultType">${qualification.resultType}</span>
                                            <div class="array" name="parameters">
                                                <c:forEach var="parameter" items="${qualification.parameters}">
                                                    <div class="object">
                                                        <span name="name">${parameter.name}</span>
                                                        <span name="notes">${parameter.notes}</span>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                                <div class="array" name="mappings">
                                    <c:forEach var="mapping" items="${model.mappings}">
                                        <div class="object">
                                            <span name="name">${mapping.name}</span>
                                            <span name="bridgeName">${mapping.bridgeName}</span>
                                            <span name="structure">${mapping.structure}</span>
                                            <div class="array" name="attributes">
                                                <c:forEach var="attribute" items="${mapping.attributeMappings}">
                                                    <div class="object">
                                                        <span name="name">${attribute.getAttributeName()}</span>
                                                        <span name="structureField">${attribute.structureField}</span>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                            <div class="array" name="qualifications">
                                                <c:forEach var="qualification" items="${mapping.qualificationMappings}">
                                                    <div class="object">
                                                        <span name="name">${qualification.getQualificationName()}</span>
                                                        <span name="query"><input type="text" value="${Text.escape(qualification.query)}" /></span>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
                
                <c:forEach var="item" items="${kapp.categories}">
                    <div class="panel panel-primary">
                        <div class="panel-heading">Category Definition <button class="btn btn-xs btn-danger pull-right"><span class="fa fa-times"></span> Remove</button></div>
                        <div class="panel-body json-container" data-container="categories">
                            <div class="object">
                                <span name="name">${item.name}</span>
                                <span name="slug">${item.slug}</span>
                            </div>
                        </div>
                    </div>
                </c:forEach>

                <c:forEach var="item" items="${kapp.formTypes}">
                    <div class="panel panel-primary">
                        <div class="panel-heading">Form Type <button class="btn btn-xs btn-danger pull-right"><span class="fa fa-times"></span> Remove</button></div>
                        <div class="panel-body json-container" data-container="formTypes">
                            <div class="object">
                                <span name="name">${item.name}</span>
                            </div>
                        </div>
                    </div>
                </c:forEach>

                <c:forEach var="form" items="${kapp.forms}">
                    <div class="panel panel-primary">
                        <div class="panel-heading">Form <button class="btn btn-xs btn-danger pull-right"><span class="fa fa-times"></span> Remove</button></div>
                        <div class="panel-body json-container" data-container="forms">
                            <div class="object">
                                <span name="name">${form.name}</span>
                                <span name="description">${form.description}</span>
                                <span name="slug">${form.slug}</span>
                                <span name="type">${form.getTypeName()}</span>
                                <span name="status">${form.status}</span>
                                <span name="anonymous"><input type="checkbox" ${form.anonymous ? 'checked' : ''} disabled/></span>
                                <span name="customHeadContent">${Text.escape(form.customHeadContent)}</span>
                                <span name="notes">${form.notes}</span>
                                <span name="submissionLabelExpression">${form.submissionLabelExpression}</span>
                                <div class="array" name="attributes">
                                    <c:forEach var="attribute" items="${form.attributes}">
                                        <div class="object">
                                            <span name="name">${attribute.getName()}</span>
                                            <div class="array" name="values">
                                                <c:forEach var="value" items="${attribute.values}">
                                                    <span name="name"><input type="text" value="${Text.escape(value)}" /></span>
                                                </c:forEach>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                                <div class="array" name="bridgedResources">
                                    <c:forEach var="bridgedResource" items="${form.bridgedResources}">
                                        <div class="object">
                                            <span name="name">${bridgedResource.name}</span>
                                            <span name="model">${bridgedResource.getModelName()}</span>
                                            <span name="qualification">${bridgedResource.getQualificationName()}</span>
                                            <span name="status">${bridgedResource.status}</span>
                                            <div class="array" name="parameters">
                                                <c:forEach var="parameter" items="${bridgedResource.parameters}">
                                                    <div class="object">
                                                        <span name="name">${parameter.getParameterName()}</span>
                                                        <span name="mapping">${parameter.mapping}</span>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                                <div class="array" name="categorizations">
                                    <c:forEach var="categorization" items="${form.categorizations}">
                                        <div class="object">
                                            <div class="object" name="category">
                                                <span name="slug">${categorization.category.slug}</span>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                                <div class="array" name="pages">
                                    <c:forEach var="page" items="${form.pages}">
                                        <div class="object json" data-json="${Text.escape(Json.toString(page.getParsedContent()))}">
                                            <span name="name">${page.name}</span>
                                            <span name="renderType"></span>
                                            <span name="type">${page.type}</span>
                                            <span name="advanceCondition">${page.advanceCondition}</span>
                                            <span name="displayCondition">${page.displayCondition}</span>
                                            <span name="displayPage">${page.displayPage}</span>
                                        </div>
                                    </c:forEach>
                                </div>
                                <div class="array" name="securityPolicies">
                                    <c:forEach var="securityPolicy" items="${form.securityPolicies}">
                                        <div class="object">
                                            <span name="endpoint">${securityPolicy.endpoint}</span>
                                            <span name="name">${securityPolicy.name}</span>
                                        </div>
                                    </c:forEach>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
                

                <c:forEach var="item" items="${kapp.securityPolicyDefinitions}">
                    <div class="panel panel-primary">
                        <div class="panel-heading">Security Policy Definitions <button class="btn btn-xs btn-danger pull-right"><span class="fa fa-times"></span> Remove</button></div>
                        <div class="panel-body json-container" data-container="securityPolicyDefinitions">
                            <div class="object">
                                <span name="name">${item.name}</span>
                                <span name="type">${item.type}</span>
                                <span name="message">${item.message}</span>
                                <span name="rule">${item.rule}</span>
                            </div>
                        </div>
                    </div>
                </c:forEach>
                
                <c:forEach var="item" items="${kapp.securityPolicies}">
                    <div class="panel panel-primary">
                        <div class="panel-heading">Security Policies <button class="btn btn-xs btn-danger pull-right"><span class="fa fa-times"></span> Remove</button></div>
                        <div class="panel-body json-container" data-container="securityPolicies">
                            <div class="object">
                                <span name="endpoint">${item.endpoint}</span>
                                <span name="name">${item.name}</span>
                            </div>
                        </div>
                    </div>
                </c:forEach>
                
                <c:forEach var="item" items="${space.webhooks}">
                    <div class="panel panel-primary">
                        <div class="panel-heading">Space Webhooks <button class="btn btn-xs btn-danger pull-right"><span class="fa fa-times"></span> Remove</button></div>
                        <div class="panel-body json-container" data-container="spaceWebhooks">
                            <div class="object">
                                <span name="name">${item.name}</span>
                                <span name="type">${item.type}</span>
                                <span name="event">${item.event}</span>
                                <span name="filter">${item.filter}</span>
                                <span name="url">${item.url}</span>
                            </div>
                        </div>
                    </div>
                </c:forEach>
                
                <c:forEach var="item" items="${kapp.webhooks}">
                    <div class="panel panel-primary">
                        <div class="panel-heading">Kapp Webhooks <button class="btn btn-xs btn-danger pull-right"><span class="fa fa-times"></span> Remove</button></div>
                        <div class="panel-body json-container" data-container="kappWebhooks">
                            <div class="object">
                                <span name="name">${item.name}</span>
                                <span name="type">${item.type}</span>
                                <span name="event">${item.event}</span>
                                <span name="filter">${item.filter}</span>
                                <span name="url">${item.url}</span>
                            </div>
                        </div>
                    </div>
                </c:forEach>
                
                
                
                <div class="panel panel-success">
                    <div class="panel-heading">
                        <h4>
                            <b>Generated setup.json</b>
                            <small class="pull-right">Minified? <input type="checkbox" class="generated-json-minified" /></small>
                        </h4>
                    </div>
                    <div class="panel-body">
                        <textarea class="generated-json"></textarea>
                    </div>
                </div>
                
            </c:otherwise>
        </c:choose>
    </div>
</bundle:layout>