/** Common JS for Setup Page and Wizard **/
(function($, _) {
    /**----------------------------------------------------------------------------------------------
     * DOM MANIPULATION AND EVENT REGISTRATION 
     *   This section is executed on page load to register events and otherwise manipulate the DOM.
     *--------------------------------------------------------------------------------------------**/
    $(function() {
        
        /***********************************************************************************************
         * Attribute Functions
         ***********************************************************************************************/
        
        // Events for attribute value manipulation
        $("div.attributes-container").on("click", "button.delete-value", function(e){
            // On click of delete button, remove the value
            $(this).closest("div.attribute-value").remove();
        }).on("click", "button.add-value", function(e){
            // On click of add button, add the value by construction the html structure
            var valueContainer = $(this).closest("div");
            var value = valueContainer.find("input").val();
            if (value.trim().length > 0){
                var newContainer = $("<div>", {class: "input-group input-group-sm attribute-value"})
                        .append($("<span>", {class: "input-group-addon label-warning"})
                                        .append($("<span>", {class: "fa fa-plus"})).append(" ")
                                        .append($("<span>", {class: "status"}).text("New")))
                        .append($("<input>", {type: "text", class: "form-control", placeholder: "Attribute Value"}).val(value))
                        .append($("<span>", {class: "input-group-btn"})
                                .append($("<button>", {type: "button", class: "btn btn-sm btn-danger delete-value"})
                                        .append($("<span>", {class: "fa fa-times"}))));
                valueContainer.before(newContainer);
                valueContainer.find("input").val("")
            }
        }).on("change", "input", function(e){
            // On change of input, if adding new value, trigger add button click
            if ($(this).closest("div").find("button.add-value").length){
                $(this).closest("div").find("button.add-value").trigger("click");
            }
            // Otherwise change the label to new in case an existing value was updated
            else {
                $(this).closest("div").find("span.input-group-addon").removeClass("label-success").addClass("label-warning").find("span.status").text("New");
                $(this).closest("div").find("span.input-group-addon").find("span.fa-check").removeClass("fa-check").addClass("fa-plus");
            }
        });
        
        // Save Attribute Configurations
        $("div.attributes-container").on("click", "button.save-configuration", function(){
            // Add loader
            $(this).notifie({
                anchor: "p.setup-actions",
                message: "<span class='fa fa-spinner fa-spin'></span> Saving Configuration",
                severity: "info",
                disable: true
            });
                        
            // Build list of attribute definitions that need to be created
            var definitions = new Array();
            $("div.attribute-definitions table tbody tr").each(function(i,e){
                if (!$(e).data("status")){
                    definitions.push({
                        name: $(e).data("name"),
                        allowsMultiple: $(e).data("allowsMultiple"),
                        level: $(e).data("level")
                    });
                }
            });
            
            // Build maps of all attribute values in the wizard
            var spaceValues = new Object();
            var kappValues = new Object();
            $("div.attribute-values table tbody tr:not(.empty-state-message)").each(function(index,attr){
                var attribute = {
                    name: $(attr).data("name"),
                    values: new Array()
                };
                if ($(attr).data("level") == "space"){
                    $(attr).find("td.space-attribute-values div.attribute-value input").each(function(i,e){
                        attribute.values.push($(e).val());
                    });
                    spaceValues[attribute.name] = attribute;
                }
                else if ($(attr).data("level") == "kapp"){
                    $(attr).find("td.kapp-attribute-values div.attribute-value input").each(function(i,e){
                        attribute.values.push($(e).val());
                    });
                    kappValues[attribute.name] = attribute;
                }
            });
            
            // Variables to use for storing data and promises
            var spaceAttributes = new Object(), 
                updateSpace = false,
                kappAttributes = new Object(),
                updateKapp = false,
                getDeferreds = new Array(),
                definitionDeferreds = new Array(),
                valueDeferreds = new Array(),
                updateDeferreds = new Array(),
                attributeErrors = new Array();

            // Get space and kapp attribute values
            getDeferreds.push($.ajax({
                method: "get",
                url: bundle.apiLocation() + "/space?include=attributes",
                success: function(data){
                    // Store the space attributes, and merge with attributes read from the wizard
                    updateSpace = mergeAttributeValues(data.space.attributes, spaceValues);
                    // Remove any attributes that have no values, and store all others
                    spaceAttributes.attributes = _.reject(data.space.attributes, function(attr){ return attr.values.length == 0; })
                },
                error: function(jqXHR, textStatus, errorThrown){
                    attributeErrors.push("Failed to retrieve Space Attributes. (" + errorThrown + ")");
                }
            }));
            getDeferreds.push($.ajax({
                method: "get",
                url: bundle.apiLocation() + "/kapps/" + bundle.kappSlug() + "?include=attributes",
                success: function(data){
                    // Store the kapp attributes, and merge with attributes read from the wizard
                    updateKapp = mergeAttributeValues(data.kapp.attributes, kappValues);
                    // Remove any attributes that have no values, and store all others
                    kappAttributes.attributes = _.reject(data.kapp.attributes, function(attr){ return attr.values.length == 0; })
                },
                error: function(jqXHR, textStatus, errorThrown){
                    attributeErrors.push("Failed to retrieve Kapp Attributes. (" + errorThrown + ")");
                }
            }));
            
            // After space and kapp attribute values are fetched, update definitions and values
            $.when.apply($, wrapDeferreds(getDeferreds)).done(function(){
                // If errors exist, show errors 
                if (attributeErrors.length > 0){
                    resolveConfigurationPage(attributeErrors, $("div.attributes-container"));
                }
                // Update all definitions and values
                else {
                    // Create all new attribute definitions
                    $.each(definitions, function(i,def){
                        var url = bundle.apiLocation();
                        if (def.level == "space" || def.level == "user"){
                            url += "/" + def.level + "AttributeDefinitions";
                        }
                        else {
                            url += "/kapps/" + bundle.kappSlug() + "/" + def.level + "AttributeDefinitions";
                        }
                        updateDeferreds.push($.ajax({
                            method: "post",
                            url: url,
                            data: JSON.stringify(def),
                            dataType: "json",
                            contentType: "application/json",
                            error: function(jqXHR, textStatus, errorThrown){
                                attributeErrors.push("Failed to create new " + def.level.charAt(0).toUpperCase() + def.level.slice(1) + " Attribute Definition with name: \"" + def.name +"\". (" + errorThrown + ")");
                            }
                        }));
                    });
                    // Update space and kapp attribute values if necessary
                    if (updateSpace){
                        updateDeferreds.push($.ajax({
                            method: "put",
                            url: bundle.apiLocation() + "/space",
                            data: JSON.stringify(spaceAttributes),
                            dataType: "json",
                            contentType: "application/json",
                            error: function(jqXHR, textStatus, errorThrown){
                                attributeErrors.push("Failed to update Space Attribute Values. (" + errorThrown + ")");
                            }
                        }));
                    }
                    if (updateKapp){
                        updateDeferreds.push($.ajax({
                            method: "put",
                            url: bundle.apiLocation() + "/kapps/" + bundle.kappSlug(),
                            data: JSON.stringify(kappAttributes),
                            dataType: "json",
                            contentType: "application/json",
                            error: function(jqXHR, textStatus, errorThrown){
                                attributeErrors.push("Failed to update Kapp Attribute Values. (" + errorThrown + ")");
                            }
                        }));
                    }
                    
                    // After definitions and values are completed, resolve the page
                    $.when.apply($, wrapDeferreds(updateDeferreds)).done(function(){
                        resolveConfigurationPage(attributeErrors, $("div.attributes-container"), bundle.kappLocation() + "?setup=wizard/attributes&step=attributes");
                    });
                }
            });
        });
        
        /**
         * Helper function used to merge existing attribute values fetched through api with values read from the wizard
         */
        function mergeAttributeValues(existingValues, wizardValues){
            // Keep track of differences
            var hasChanges = false;
            // For all existing attributes, check if wizard contains that attribute
            $.each(existingValues, function(i, attr){
                // If it does, check if the values in the wizard are different from those that are already stored
                if (wizardValues[attr.name] != null){
                    // If values are different, use the values from the wizard
                    if (_.difference(attr.values, wizardValues[attr.name].values).length || _.difference(wizardValues[attr.name].values, attr.values).length){
                        attr.values = wizardValues[attr.name].values;
                        hasChanges = true;
                    }
                    delete wizardValues[attr.name];
                }
            });
            // For all attributes that exist in the wizard but are not yet saved, add them to the list
            $.each(wizardValues, function(k, attr){
                if (attr.values.length > 0){
                    existingValues.push(attr);
                    hasChanges = true;
                }
            });
            // Return true if the wizard has values that need to be saved
            return hasChanges;
        }       
        
        
        /***********************************************************************************************
         * Bridge Functions
         ***********************************************************************************************/
        
        // Save Bridge Configurations
        $("div.bridges-container").on("click", "button.save-configuration", function(){
            // Add loader
            $(this).notifie({
                anchor: "p.setup-actions",
                message: "<span class='fa fa-spinner fa-spin'></span> Saving Configuration",
                severity: "info",
                disable: true
            });
            
            var bridgeErrors = new Array();
                        
            // Build list of bridges that need to be created
            var bridges = new Array();
            $("div.bridges table tbody tr").each(function(i,e){
                var bridge = $(e).data("json");
                if (!bridge.exists){
                    bridges.push(bridge);
                }
            });
            
            // Build list of bridge models and mappings that need to be created
            var bridgeModels = new Array();
            var bridgeMappings = new Array();
            $("div.bridge-models table tbody tr").each(function(i,e){
                var model = $(e).data("json");
                $.each(model.mappings, function(j,mapping){
                    if (!mapping.exists){
                        mapping.modelName = model.name;
                        bridgeMappings.push(mapping);
                    }
                });
                if (!model.exists){
                    delete model.mappings;
                    bridgeModels.push(model);
                }
            });
        
            // Store promises for all ajax calls
            var deferreds = new Array();
            // Create bridges
            $.each(bridges, function(i,bridge){
                deferreds.push($.ajax({
                    method: "post",
                    url: bundle.apiLocation() + "/bridges",
                    data: JSON.stringify(bridge),
                    dataType: "json",
                    contentType: "application/json",
                    error: function(jqXHR, textStatus, errorThrown){
                        bridgeErrors.push("Failed to create new Bridge with name: \"" + bridge.name + "\". (" + errorThrown + ")");
                    }
                }));
            });
            // Create bridge models
            $.each(bridgeModels, function(i,model){
                deferreds.push($.ajax({
                    method: "post",
                    url: bundle.apiLocation() + "/models",
                    data: JSON.stringify(model),
                    dataType: "json",
                    contentType: "application/json",
                    error: function(jqXHR, textStatus, errorThrown){
                        bridgeErrors.push("Failed to create new Bridge Model with name: \"" + model.name + "\". (" + errorThrown + ")");
                    }
                }));
            });
            
            // After bridges and bridge models are finished processing
            $.when.apply($, wrapDeferreds(deferreds)).done(function(){
                // If errors exist, show errors and skip saving mappings
                if (bridgeErrors.length > 0){
                    resolveConfigurationPage(bridgeErrors, $("div.bridges-container"), bundle.kappLocation() + "?setup=wizard/bridges&step=bridges");
                }
                // Save mappings
                else {
                    var mappingDeferreds = new Array();
                    // Create bridge mappings
                    $.each(bridgeMappings, function(i,mapping){
                        mappingDeferreds.push($.ajax({
                            method: "post",
                            url: bundle.apiLocation() + "/models/" + mapping.modelName + "/mappings",
                            data: JSON.stringify(mapping),
                            dataType: "json",
                            contentType: "application/json",
                            error: function(jqXHR, textStatus, errorThrown){
                                bridgeErrors.push("Failed to create new Bridge Mapping with name: \"" + mapping.name + "\" for Model: \"" + mapping.modelName + "\". (" + errorThrown + ")");
                            }
                        }));
                    });
                    
                    $.when.apply($, wrapDeferreds(mappingDeferreds)).done(function(){
                        resolveConfigurationPage(bridgeErrors, $("div.bridges-container"), bundle.kappLocation() + "?setup=wizard/bridges&step=bridges");
                    });
                }
            });
            
        });
        
        /***********************************************************************************************
         * Category Functions
         ***********************************************************************************************/
        
        // Save Category Configurations
        $("div.categories-container").on("click", "button.save-configuration", function(){
            // Add loader
            $(this).notifie({
                anchor: "p.setup-actions",
                message: "<span class='fa fa-spinner fa-spin'></span> Saving Configuration",
                severity: "info",
                disable: true
            });
            
            var categoryErrors = new Array();
                        
            // Build list of categories that need to be created
            var categories = new Array();
            $("div.category-definitions table tbody tr").each(function(i,e){
                if (!$(e).data("status")){
                    categories.push($(e).data("json"));
                }
            });
            
            // Store promises for all ajax calls
            var deferreds = new Array();
            // Create categories
            $.each(categories, function(i,category){
                deferreds.push($.ajax({
                    method: "post",
                    url: bundle.apiLocation() + "/kapps/" + bundle.kappSlug() + "/categories",
                    data: JSON.stringify(category),
                    dataType: "json",
                    contentType: "application/json",
                    error: function(jqXHR, textStatus, errorThrown){
                        categoryErrors.push("Failed to create new Category with slug: \"" + category.slug + "\". (" + errorThrown + ")");
                    }
                }));
            });
            
            // After categories are finished processing, resolve the page
            $.when.apply($, wrapDeferreds(deferreds)).done(function(){
                resolveConfigurationPage(categoryErrors, $("div.categories-container"), bundle.kappLocation() + "?setup=wizard/categories&step=categories");
            });
            
        });
        
        
        /***********************************************************************************************
         * Form Type Functions
         ***********************************************************************************************/
        
        // Save Category Configurations
        $("div.form-types-container").on("click", "button.save-configuration", function(){
            // Add loader
            $(this).notifie({
                anchor: "p.setup-actions",
                message: "<span class='fa fa-spinner fa-spin'></span> Saving Configuration",
                severity: "info",
                disable: true
            });
            
            var formTypeErrors = new Array();
                        
            // Build list of categories that need to be created
            var formTypes = new Array();
            $("div.form-types table tbody tr").each(function(i,e){
                if (!$(e).data("status")){
                    formTypes.push($(e).data("json"));
                }
            });
            
            // Store promises for all ajax calls
            var deferreds = new Array();
            // Create categories
            $.each(formTypes, function(i,formType){
                deferreds.push($.ajax({
                    method: "post",
                    url: bundle.apiLocation() + "/kapps/" + bundle.kappSlug() + "/formTypes",
                    data: JSON.stringify(formType),
                    dataType: "json",
                    contentType: "application/json",
                    error: function(jqXHR, textStatus, errorThrown){
                        formTypeErrors.push("Failed to create new Form Type with name: \"" + formType.name + "\". (" + errorThrown + ")");
                    }
                }));
            });
            
            // After categories are finished processing, resolve the page
            $.when.apply($, wrapDeferreds(deferreds)).done(function(){
                resolveConfigurationPage(formTypeErrors, $("div.form-types-container"), bundle.kappLocation() + "?setup=wizard/formTypes&step=formTypes");
            });
            
        });
        
        /***********************************************************************************************
         * Form Functions
         ***********************************************************************************************/
        
        // Save Form Configurations
        $("div.forms-container").on("click", "button.save-configuration", function(){
            // Add loader
            $(this).notifie({
                anchor: "p.setup-actions",
                message: "<span class='fa fa-spinner fa-spin'></span> Saving Configuration",
                severity: "info",
                disable: true
            });
            
            var formErrors = new Array();
                        
            // Build list of forms that need to be created
            var forms = new Array();
            $("div.forms table tbody tr").each(function(i,e){
                var form = $(e).data("json");
                if (!form.exists){
                    forms.push(form);
                }
            });
            
            // Store promises for all ajax calls
            var deferreds = new Array();
            // Create forms
            $.each(forms, function(i,form){
                deferreds.push($.ajax({
                    method: "post",
                    url: bundle.apiLocation() + "/kapps/" + bundle.kappSlug() + "/forms",
                    data: JSON.stringify(form),
                    dataType: "json",
                    contentType: "application/json",
                    error: function(jqXHR, textStatus, errorThrown){
                        formErrors.push("Failed to create new Form with slug: \"" + form.slug + "\". (" + errorThrown + ")");
                    }
                }));
            });
            
            // After forms are finished processing, resolve the page
            $.when.apply($, wrapDeferreds(deferreds)).done(function(){
                resolveConfigurationPage(formErrors, $("div.forms-container"), bundle.kappLocation() + "?setup=wizard/forms&step=forms");
            });
        
        });
        
        
        /***********************************************************************************************
         * Security Functions
         ***********************************************************************************************/
        
        // Save Security Configurations
        $("div.security-container").on("click", "button.save-configuration", function(){
            // Add loader
            $(this).notifie({
                anchor: "p.setup-actions",
                message: "<span class='fa fa-spinner fa-spin'></span> Saving Configuration",
                severity: "info",
                disable: true
            });
            
            var securityErrors = new Array();
                        
            // Build list of security policy definitions that need to be created
            var securityPolicyDefinitions = new Array();
            $("div.security-policy-definitions table tbody tr").each(function(i,e){
                if (!$(e).data("status")){
                    securityPolicyDefinitions.push($(e).data("json"));
                }
            });
            
            // Build map of security policies from wizard page
            var securityPolicies = new Object(),
                updateSecurityPolicies = false;
            $("div.security-policies table tbody tr").each(function(index,attr){
                var securityPolicy = $(attr).data("json");
                if (!$(attr).data("status")){
                    securityPolicies[securityPolicy.endpoint] = securityPolicy;
                    updateSecurityPolicies = true;
                }
            });
            
            // Variables to use for storing data and promises
            var existingSecurityPolicies = new Object(),
                getDeferreds = new Array();
            // Get kapp security policies
            getDeferreds.push($.ajax({
                method: "get",
                url: bundle.apiLocation() + "/kapps/" + bundle.kappSlug() + "?include=securityPolicies",
                success: function(data){
                    existingSecurityPolicies.securityPolicies = data.kapp.securityPolicies;
                    if (updateSecurityPolicies){
                        // For all existing security policies, check if wizard contains that policy
                        $.each(existingSecurityPolicies.securityPolicies, function(i, policy){
                            // If it does, update the policy for the endpoint
                            if (securityPolicies[policy.endpoint] != null){
                                // If values are different, use the name from the wizard
                                policy.name = securityPolicies[policy.endpoint].name;
                                delete securityPolicies[policy.endpoint];
                            }
                        });
                        // For all security policies that exist in the wizard but don't yet exist, add them to the list
                        $.each(securityPolicies, function(k, policy){
                            existingSecurityPolicies.securityPolicies.push(policy);
                        });
                    }
                },
                error: function(jqXHR, textStatus, errorThrown){
                    securityErrors.push("Failed to retrieve Kapp Security Policies. (" + errorThrown + ")");
                }
            }));
            
            // After kapp security polcies are fetched, update definitions and policies
            $.when.apply($, wrapDeferreds(getDeferreds)).done(function(){
                // If errors exist, show errors 
                if (securityErrors.length > 0){
                    resolveConfigurationPage(securityErrors, $("div.security-container"));
                }
                else {
                    
                    // Store promises for all ajax calls
                    var updateDeferreds = new Array();
                    // Create security policy definitions
                    $.each(securityPolicyDefinitions, function(i,securityPolicyDefinition){
                        updateDeferreds.push($.ajax({
                            method: "post",
                            url: bundle.apiLocation() + "/kapps/" + bundle.kappSlug() + "/securityPolicyDefinitions",
                            data: JSON.stringify(securityPolicyDefinition),
                            dataType: "json",
                            contentType: "application/json",
                            error: function(jqXHR, textStatus, errorThrown){
                                securityErrors.push("Failed to create new Security Policy Definition with name: \"" + securityPolicyDefinition.name + "\". (" + errorThrown + ")");
                            }
                        }));
                    });
                    // Update kapp security polcies if necessary
                    if (updateSecurityPolicies){
                        updateDeferreds.push($.ajax({
                            method: "put",
                            url: bundle.apiLocation() + "/kapps/" + bundle.kappSlug(),
                            data: JSON.stringify(existingSecurityPolicies),
                            dataType: "json",
                            contentType: "application/json",
                            error: function(jqXHR, textStatus, errorThrown){
                                securityErrors.push("Failed to update Kapp Security Policies. (" + errorThrown + ")");
                            }
                        }));
                    }
                    // After security is finished processing, resolve the page
                    $.when.apply($, wrapDeferreds(updateDeferreds)).done(function(){
                        resolveConfigurationPage(securityErrors, $("div.security-container"), bundle.kappLocation() + "?setup=wizard/security&step=security");
                    });
                }
            });
            
        });
        
        /***********************************************************************************************
         * Webhook Functions
         ***********************************************************************************************/
        
        // Save Category Configurations
        $("div.webhooks-container").on("click", "button.save-configuration", function(){
            // Add loader
            $(this).notifie({
                anchor: "p.setup-actions",
                message: "<span class='fa fa-spinner fa-spin'></span> Saving Configuration",
                severity: "info",
                disable: true
            });
            
            var webhookErrors = new Array();
                        
            // Build list of webhooks that need to be created
            var spaceWebhooks = new Array();
            var kappWebhooks = new Array();
            $("div.webhooks table tbody tr").each(function(i,e){
                if (!$(e).data("status")){
                    if ($(e).data("level") == "space"){
                        spaceWebhooks.push($(e).data("json"));
                    }
                    else if ($(e).data("level") == "kapp"){
                        kappWebhooks.push($(e).data("json"));
                    }
                }
            });
            
            // Store promises for all ajax calls
            var deferreds = new Array();
            // Create webhooks
            $.each(spaceWebhooks, function(i,webhook){
                deferreds.push($.ajax({
                    method: "post",
                    url: bundle.apiLocation() + "/webhooks",
                    data: JSON.stringify(webhook),
                    dataType: "json",
                    contentType: "application/json",
                    error: function(jqXHR, textStatus, errorThrown){
                        webhookErrors.push("Failed to create new Space Webhook with name: \"" + webhook.name + "\". (" + errorThrown + ")");
                    }
                }));
            });
            $.each(kappWebhooks, function(i,webhook){
                deferreds.push($.ajax({
                    method: "post",
                    url: bundle.apiLocation() + "/kapps/" + bundle.kappSlug() + "/webhooks",
                    data: JSON.stringify(webhook),
                    dataType: "json",
                    contentType: "application/json",
                    error: function(jqXHR, textStatus, errorThrown){
                        webhookErrors.push("Failed to create new Kapp Webhook with name: \"" + webhook.name + "\". (" + errorThrown + ")");
                    }
                }));
            });
            
            // After categories are finished processing, resolve the page
            $.when.apply($, wrapDeferreds(deferreds)).done(function(){
                resolveConfigurationPage(webhookErrors, $("div.webhooks-container"), bundle.kappLocation() + "?setup=wizard/webhooks&step=webhooks");
            });
            
        });
        
        /***********************************************************************************************
         * Admin Kapp Form Functions
         ***********************************************************************************************/
        
        // Save Admin Kapp Form Configurations
        $("div.admin-kapp-forms-container").on("click", "button.save-configuration", function(){
            // Add loader
            $(this).notifie({
                anchor: "p.setup-actions",
                message: "<span class='fa fa-spinner fa-spin'></span> Saving Configuration",
                severity: "info",
                disable: true
            });
            
            var formErrors = new Array();
                        
            // Build list of forms that need to be created
            var forms = new Array();
            $("div.custom-admin-kapp-forms table tbody tr:not(.empty-state-message)").each(function(i,e){
                var form = $(e).data("json");
                if (!form.exists){
                    forms.push(form);
                }
            });
            
            // Store promises for all ajax calls
            var deferreds = new Array();
            // Create forms
            $.each(forms, function(i,form){
                console.log(JSON.stringify(form));
                deferreds.push($.ajax({
                    method: "post",
                    url: bundle.apiLocation() + "/kapps/" + $("div.custom-admin-kapp-forms").data("admin-kapp-slug") + "/forms",
                    data: JSON.stringify(form),
                    dataType: "json",
                    contentType: "application/json",
                    error: function(jqXHR, textStatus, errorThrown){
                        formErrors.push("Failed to create new Form in the Admin Kapp with slug: \"" + form.slug + "\". (" + errorThrown + ")");
                    }
                }));
            });
            
            // After forms are finished processing, resolve the page
            $.when.apply($, wrapDeferreds(deferreds)).done(function(){
                resolveConfigurationPage(formErrors, $("div.admin-kapp-forms-container"), bundle.kappLocation() + "?setup=wizard/adminKappForms&step=adminKappForms");
            });
        
        });
        
        
    });

    /**----------------------------------------------------------------------------------------------
     * COMMON INIALIZATION 
     *   This code is executed when the Javascript file is loaded
     *--------------------------------------------------------------------------------------------**/
    // Ensure the BUNDLE global object exists
    bundle = typeof bundle !== "undefined" ? bundle : {};
    // Create namespace for the Setup Page and Wizard
    bundle.admin = bundle.setup || {};
    // Create a scoped alias to simplify references to your namespace
    var setup = bundle.setup;

    /**----------------------------------------------------------------------------------------------
     * COMMON FUNCTIONS
     *--------------------------------------------------------------------------------------------**/
    
    function resolveConfigurationPage(errors, container, reloadPageUrl){
        // Build display string of errors
        var error = "";
        $.each(errors, function(i,err){
            if (error.length > 0){
                error += "<br>";
            }
            error += err;
        });
        // Create deferred object to wait for page reaload if needed
        var resolution = $.Deferred();
        // If reload is needed, refresh the page and replace the content
        if (reloadPageUrl){
            $.ajax({
                method: "get",
                url: reloadPageUrl,
                success: function(data){
                    container.html(data);
                },
                error: function(jqXHR, textStatus, errorThrown){
                    error = "Failed to reload the page. Please refresh. (" + errorThrown +")<br>" + error;
                },
                complete: function(){
                    // Resolve the deferred when done
                    resolution.resolve();
                } 
            })
        }
        // Otherwise just resolve the deferred
        else {
            resolution.resolve();
        }
        // When the resolution deferred is done, display message with either errors or success
        resolution.done(function(){
            if (error.length > 0){
                // Add error
                container.find("button.save-configuration").notifie({
                    anchor: "p.setup-actions",
                    message: error,
                    severity: "danger"
                });
            }
            else {
                container.find("button.save-configuration").notifie({
                    anchor: "p.setup-actions",
                    message: "The configurations were saved successfully.",
                    severity: "success"
                });
            }
        });
    }
    
    function wrapDeferreds(deferreds){
        return $.map(deferreds, function(d) {
            var wrapedDeferred = $.Deferred();
            d.always(function() { wrapedDeferred.resolve(); });
            return wrapedDeferred.promise();
        });
    }
    
})($, _);