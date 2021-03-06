/* JS Specific to the Datastore Console */
(function($, _) {
    /*----------------------------------------------------------------------------------------------
     * DOM MANIPULATION AND EVENT REGISTRATION 
     *   This section is executed on page load to register events and otherwise manipulate the DOM.
     *--------------------------------------------------------------------------------------------*/
    $(function() {

        /******************************************************************************************
         ** START *** DATASTORE/CONSOLE PAGE *** DOCUMENT READY CODE
         ** Lists all datastores.
         ******************************************************************************************/

        // If on console page
        if ($("table.datastore-list-table").length){
            // Clear DataTables attribute from local storage to remove save state of datastores
            Object.keys(window.localStorage).forEach(function(key){
                var re = new RegExp("^DataTables_datastore-records-table.*?" + window.location.pathname.replace(/\/$/, "") + ".*");
                if (re.test(key)) {
                    window.localStorage.removeItem(key);
                }
            });
        }
        
        /**
         * Initialize DataTable for dom sourced tables
         */
        $("table[data-table-dom]").each(function(i,table){
            var options = {
                autoWidth: false,
                pageLength: 25,
                language: {
                    search: "Filter"
                },
                drawCallback: function(){
                    $("[data-tooltip]").tooltip();
                }
            };
            if ($(table).data("empty-message")){
                options.language.emptyTable = $(table).data("empty-message");
            }
            $(table).dataTable(options);
            $(table).on("click", "td", function(e){
                if (e.target == this){
                    $(this).closest("tr").toggleClass("full-text");
                }
            });
            $(table).parent().find("div.dt-title").prepend($("<h4>", {class: "pull-left"}).append($(table).data("table-name")));
        });
        
        /** END *** DATASTORE/CONSOLE PAGE *** DOCUMENT READY CODE *********************************/

        /******************************************************************************************
         ** START *** DATASTORE/CONFIG PAGE *** DOCUMENT READY CODE
         ** Allows for creating of new datastore forms and updating those forms.
         ******************************************************************************************/
        
        /**
         * Event handler for creating a new datastore.
         */
        $("button#create-datastore").on("click", function(){
            // Store instance to this button and form
            var self = $(this);
            var form = self.closest("form");
            // Function for displaying errors
            var createError = function(e){
                self.notifie({
                    anchor: "form",
                    message: "Failed to create a new datastore.<br>" + e,
                    exitEvents: "click",
                    disable: false,
                    margin: {"margin-bottom":"10px"}
                });
            }
            // Get field data
            var fieldData = {
                name: form.find("input#datastore-name").val(),
                slug: form.find("input#datastore-slug").val(),
                description: form.find("textarea#datastore-description").val(),
                status: "Active",
                type: "Datastore"
            };
            
            /** Make ajax call to get json template for creating a new datastore form **/
            $.ajax({
                url: bundle.apiLocation() + "/kapps/" + bundle.adminDatastore.kappSlug 
                     + "/forms/datastore-template" 
                     + "?include=attributes,pages,securityPolicies",
                beforeSend: function(jqXHR, settings){
                    self.prop("disabled", true);
                },
                success: function(template, textStatus, jqXHR){
                    try {
                        /** Make ajax call to create new form using json from above ajax call and form fields from the screen **/
                        $.ajax({
                            method: "POST",
                            url: bundle.apiLocation() + "/kapps/" + bundle.kappSlug() + "/forms?include=fields",
                            dataType: "json",
                            data: JSON.stringify($.extend(true, template.form, fieldData)),
                            contentType: "application/json",
                            success: function(data, textStatus, jqXHR){
                                // Define url to redirect to
                                var redirectUrl = bundle.kappLocation() + "/" + self.data("console-slug")
                                        + "?page=" + self.data("console-slug") + "/config&store=" + data.form.slug;
                                // Get bridge dropdown
                                var bridgeSelect = form.find("select#datastore-bridge");
                                
                                /** If bridge is selected, create/update bridge model and mapping **/
                                if (bridgeSelect.val().length > 0){
                                    // Build model ajax options with data
                                    var bridgeModelAjaxOptions = buildAttributeModelAjaxOptions("Datastore - " + data.form.name, 
                                            bridgeSelect, 
                                            form.find("table#qualification-table"), 
                                            data.form);
                                    // Build mapping ajax options with data
                                    var bridgeMappingAjaxOptions = buildAttributeMappingAjaxOptions("Datastore - " + data.form.name, 
                                            bridgeSelect, 
                                            form.find("table#qualification-table"), 
                                            data.form);
                                    
                                    /** Perform ajax call to create/update bridge model **/
                                    $.ajax($.extend(true, bridgeModelAjaxOptions, {
                                            success: function(data, textStatus, jqXHR){
                                                /** Perform ajax call to update bridge mapping **/
                                                $.ajax($.extend(true, bridgeMappingAjaxOptions, {
                                                        success: function(data, textStatus, jqXHR){
                                                            // Redirect to update datastore page on success
                                                            location.href = redirectUrl;
                                                        },
                                                        error: function(jqXHR, textStatus, errorThrown){
                                                            (new KD.Modal({
                                                                header: "Error",
                                                                body: "There was an error building the bridge mapping: " + errorThrown,
                                                                footer: function(element, actions) {
                                                                    element.addClass("text-right").append(
                                                                        $("<button>", {class: "btn btn-default"}).text("OK").on("click", actions.dismiss)
                                                                    );
                                                                },
                                                                size: "sm",
                                                                backdrop: true,
                                                                backdropclose: true,
                                                                keyboardclose: true,
                                                                renderCallback: false,
                                                                dismiss: function(){
                                                                    // Redirect to update datastore page on success
                                                                    location.href = redirectUrl;
                                                                }
                                                            })).show();
                                                        }
                                                    }));
                                            },
                                            error: function(jqXHR, textStatus, errorThrown){
                                                (new KD.Modal({
                                                    header: "Error",
                                                    body: "There was an error building the bridge model: " + errorThrown,
                                                    footer: function(element, actions) {
                                                        element.addClass("text-right").append(
                                                            $("<button>", {class: "btn btn-default"}).text("OK").on("click", actions.dismiss)
                                                        );
                                                    },
                                                    size: "sm",
                                                    backdrop: true,
                                                    backdropclose: true,
                                                    keyboardclose: true,
                                                    renderCallback: false,
                                                    dismiss: function(){
                                                        // Redirect to update datastore page on success
                                                        location.href = redirectUrl;
                                                    }
                                                })).show();
                                            }
                                        }));
                                }
                                else {
                                    // Redirect to update datastore page on success
                                    location.href = redirectUrl;
                                }
                            },
                            error: function(jqXHR, textStatus, errorThrown){
                                createError(JSON.parse(jqXHR.responseText).error);
                                self.prop("disabled", false);
                            }
                        });
                    }
                    catch (e){
                        createError("Please contact an administrator.<br>" + e.message);
                    }
                },
                error: function(jqXHR, textStatus, errorThrown){
                    createError("Please contact an administrator.<br>" + errorThrown);
                }
            });
        });
        
        /**
         * Event handlers for mirroring name field input into slug when creating datastore.
         */
        $("form#create-datastore-form").on("keyup", "input#datastore-name", function(){
            $("input#datastore-slug").val($(this).val().trim().toLowerCase().replace(/[^a-z0-9\s-]/g, "").replace(/\s+/g, "-"));
        }).on("keyup", "input#datastore-slug", function(){
            $(this).val($(this).val().trim().toLowerCase().replace(/[^a-z0-9\s-]/g, "").replace(/\s+/g, "-"));
        }).one("keyup", "input#datastore-slug", function(){
            $("form#create-datastore-form").off("keyup", "input#datastore-name");
        });
        
        /**
         * Event handler for updating a datastore.
         */
        $("button#update-datastore").on("click", function(){
            // Store instance to this button and form
            var self = $(this);
            var form = self.closest("form");
            // Get field data
            var fieldData = {
                name: form.find("input#datastore-name").val(),
                slug: form.find("input#datastore-slug").val(),
                description: form.find("textarea#datastore-description").val(),
                attributes: buildDatastoreConfigurationAttribute(form.find("table#column-table"))
            };

            /** Make ajax call to update datastore with data from the form fields on the screen **/
            $.ajax({
                method: "PUT",
                url: bundle.apiLocation() + "/kapps/" + bundle.kappSlug() + "/forms/" + self.data("datastore-slug") + "?include=fields",
                dataType: "json",
                data: JSON.stringify(fieldData),
                contentType: "application/json",
                beforeSend: function(jqXHR, settings){  
                    self.prop("disabled", true);
                },
                success: function(data, textStatus, jqXHR){
                    // Define url so we can reload
                    var reloadUrl = bundle.kappLocation() + "/" + self.data("console-slug")
                            + "?page=" + self.data("console-slug") + "/config&store=" + data.form.slug;
                    // Get bridge dropdown
                    var bridgeSelect = form.find("select#datastore-bridge");
                    
                    /** If bridge is selected, create/update bridge model and mapping **/
                    if (bridgeSelect.val().length > 0){
                        // Build model ajax options with data
                        var bridgeModelAjaxOptions = buildAttributeModelAjaxOptions("Datastore - " + data.form.name, 
                                bridgeSelect, 
                                form.find("table#qualification-table"), 
                                data.form);
                        // Build mapping ajax options with data
                        var bridgeMappingAjaxOptions = buildAttributeMappingAjaxOptions("Datastore - " + data.form.name, 
                                bridgeSelect, 
                                form.find("table#qualification-table"), 
                                data.form);
                        
                        /** Perform ajax call to create/update bridge model **/
                        $.ajax($.extend(true, bridgeModelAjaxOptions, {
                                success: function(data, textStatus, jqXHR){
                                    /** Perform ajax call to update bridge mapping **/
                                    $.ajax($.extend(true, bridgeMappingAjaxOptions, {
                                            success: function(data, textStatus, jqXHR){
                                                location.href = reloadUrl;
                                            },
                                            error: function(jqXHR, textStatus, errorThrown){
                                                (new KD.Modal({
                                                    header: "Error",
                                                    body: "There was an error building the bridge mapping: " + errorThrown,
                                                    footer: function(element, actions) {
                                                        element.addClass("text-right").append(
                                                            $("<button>", {class: "btn btn-default"}).text("OK").on("click", actions.dismiss)
                                                        );
                                                    },
                                                    size: "sm",
                                                    backdrop: true,
                                                    backdropclose: true,
                                                    keyboardclose: true,
                                                    renderCallback: false,
                                                    dismiss: function(){
                                                        // Redirect to update datastore page on success
                                                        location.href = reloadUrl;
                                                    }
                                                })).show();
                                            }
                                        }));
                                },
                                error: function(jqXHR, textStatus, errorThrown){
                                    (new KD.Modal({
                                        header: "Error",
                                        body: "There was an error building the bridge model: " + errorThrown,
                                        footer: function(element, actions) {
                                            element.addClass("text-right").append(
                                                $("<button>", {class: "btn btn-default"}).text("OK").on("click", actions.dismiss)
                                            );
                                        },
                                        size: "sm",
                                        backdrop: true,
                                        backdropclose: true,
                                        keyboardclose: true,
                                        renderCallback: false,
                                        dismiss: function(){
                                            // Redirect to update datastore page on success
                                            location.href = reloadUrl;
                                        }
                                    })).show();
                                }
                            }));
                    }
                    else {
                        // Reload page on success
                        location.href = reloadUrl;
                    }
                },
                error: function(jqXHR, textStatus, errorThrown){
                    self.notifie({
                        anchor: "form",
                        message: "Failed to update the datastore.<br>" + JSON.parse(jqXHR.responseText).error,
                        exitEvents: "click",
                        disable: false,
                        margin: {"margin-top":"10px", "margin-bottom":"10px"}
                    });
                    self.prop("disabled", false);
                }
            });
        });
        
        /**
         * Make column table sortable
         */
        $( "table#column-table tbody" ).sortable({
            axis: "y",
            items: "tr",
            containment: $("form"),
            opacity: 0.5,
            placeholder: "column-table-placeholder",
            helper: function(e, ui) {  
                ui.children().each(function() {  
                    $(this).width($(this).width());  
                });  
                return ui;  
            }
        });
        
        // Run the below code if table#qualification-table exists
        if ($("table#qualification-table").length){
            
            /**
             * Remove duplicate parameters
             */
            $("table#qualification-table div.modal-params").each(function(i, modalParams){
                $(modalParams).find("table#params-table td.param-name").each(function(j, td){
                    $(modalParams).find("td.param-add-value select").val("")
                                  .find("option[value='" + $(td).text() + "']").remove();
                });
            });
            
            /**
             * Event handler for parameters link which builds and destroys the modal, keeping the data hidden in the dom.
             */
            $("table#qualification-table").on("click", "a.qualification-modal-link", function(e){
                var modalParams = $(this).siblings('div.modal-params');
                var modalBody = $("<div>");
                // Build confirmation dialog
                var parameterModal = new KD.Modal({
                    header: "Bridge Parameters",
                    body: function(element, actions) {
                        // Move parameters table from body (where it's hidden) to the modal
                        modalBody.append(modalParams.children())
                            // Append to element
                            .appendTo(element)
                            // Event handler for delete parameter button
                            .on("click", "td.param-actions button.param-delete", function(e){
                                var paramName = $(this).closest("tr").find("td.param-name").text();
                                modalBody.find("td.param-add-value select").append($("<option>", {value: paramName}).append(paramName));
                                $(this).closest("tr").remove();
                            })
                            // Event handler for add parameter button
                            .on("click", "td.param-add-btn button", function(e){
                                // Get new parameter name
                                var paramName = $(this).closest("tr").find("td.param-add-value select").val();
                                // If parameter doesn't already exist, add it
                                if (paramName){
                                    var template = _.template($("div.hidden-qual-params-row-template > table > tbody").html());
                                    modalBody.find("table#params-table tbody")
                                             .append(template({parameterName: paramName, parameterValue: null}));
                                    modalBody.find("td.param-add-value select").val("")
                                             .find("option[value='" + paramName + "']").remove();
                                }
                            });
                    },
                    footer: function(element, actions) {
                        element.addClass("text-right").append(
                            $("<button>", {class: "btn btn-default"}).text("Done").on("click", function(){
                                actions.dismiss();
                            })
                        );
                    },
                    size: "md",
                    backdrop: true,
                    backdropclose: true,
                    keyboardclose: true,
                    renderCallback: false,
                    dismiss: function(){
                        modalParams.append(modalBody.children());
                        modalParams.siblings("a.qualification-modal-link").find("span.param-count").text(modalParams.find("table#params-table tbody tr").length);
                    }
                });
                // Show confirmation dialog
                parameterModal.show();
                $(this).blur();
            });
            
            /**
             * Event handler for adding new qualifications
             */
            $("table#add-qualification-table").on("click", "td.qual-add-btn button", function(e){
                var qualName = $("table#add-qualification-table").find("td.qual-add-name input").val().trim();
                var qualResultType = $("table#add-qualification-table").find("td.qual-add-result-type select").val();
                
                if (qualName.length <= 0){
                    $(this).notifie({
                        anchor: "table#add-qualification-table",
                        message: "Qualification name is required.",
                        exitEvents: "click"
                    });
                }
                else {
                    var newQualParams = $("div.hidden-qual-params-template").clone();
                    if (qualResultType != 'Single'){
                        newQualParams.find("td.param-add-value select option[value='Submission ID']").remove();
                    }
                    newQualParams.find("span.param-count").text("0");
                    var newQualRow = $("<tr>", {class: "qualification-row"})
                                .append($("<td>", {class: "qual-name"}).text(qualName))
                                .append($("<td>", {class: "qual-result-type"}).text(qualResultType))
                                .append($("<td>", {class: "qual-params"}).append(newQualParams.children()))
                                .append($("<td>", {class: "qual-actions"}).append($("div.hidden-qual-actions-template").clone().children()));
                    $("table#qualification-table > tbody").append(newQualRow);
                    $("table#add-qualification-table").find("td.qual-add-name input").val("");
                    $("table#add-qualification-table").find("td.qual-add-result-type select").prop('selectedIndex', 0)
                }
            })
            
            /**
             * Event handlers for edit, delete, cancel edit, and save edit buttons for a qualification
             */
            $("table#qualification-table").on("click", "td.qual-actions button.qual-edit", function(e){
                // Change qualification row to be editable
                var row = $(this).closest("tr");
                // Replace name text with input field
                row.find("td.qual-name").html($("<input>", {
                        value: row.find("td.qual-name").text(), 
                        class: "input-sm form-control", 
                        placeholder: "Qualification Name", 
                        "data-name": row.find("td.qual-name").text()
                    }));
                // Replace rsult type text with dropdown
                row.find("td.qual-result-type").html($("<select>", {
                        class: "input-sm form-control",
                        "data-result-type": row.find("td.qual-result-type").text()
                    }).append($("<option>", {value: "Multiple"}).text("Multiple"))
                        .append($("<option>", {value: "Single"}).text("Single"))
                        .val(row.find("td.qual-result-type").text()));
                // Hide standard action buttons and show edit action buttons
                row.find("div.qual-actions").addClass("hide");
                row.find("div.qual-edit-actions").removeClass("hide");
            })
            .on("click", "button.qual-delete", function(e){
                // Delete the row, but confirm deletion first
                var row = $(this).closest("tr");
                // Create Modal to confirm delete
                var confirmDelete = new KD.Modal({
                    header: "Confirm Delete",
                    body: "Are you sure you want to delete this qualification?",
                    footer: function(element, actions) {
                        element.addClass("text-right").append(
                            $("<button>", {class: "btn btn-success"}).text("Yes").on("click", actions.accept),
                            $("<button>", {class: "btn btn-link"}).text("Cancel").on("click", actions.dismiss)
                        );
                    },
                    size: "sm",
                    backdrop: true,
                    backdropclose: true,
                    keyboardclose: true,
                    renderCallback: false,
                    accept: function(){
                        row.remove();
                    }
                });
                // Show confirmation dialog
                confirmDelete.show();
                // Blur delete button
                $(this).blur();
            })
            .on("click", "button.qual-cancel-edit", function(e){
                // Cancel editing of qualification row
                var row = $(this).closest("tr");
                // Replace name input with text value
                row.find("td.qual-name").text(row.find("td.qual-name input").data("name"));
                // Replace result type dropdown with text value
                row.find("td.qual-result-type").text(row.find("td.qual-result-type select").data("result-type"));
                // Hide edit action buttons and show standard action buttons
                row.find("div.qual-edit-actions").addClass("hide");
                row.find("div.qual-actions").removeClass("hide");
            })
            .on("click", "button.qual-save-edit", function(e){
                // Close editing of qualification row and keep changes
                var row = $(this).closest("tr");
                // Get new qualification name
                var qualName = row.find("td.qual-name input").val().trim();
                if (qualName.length <= 0){
                    row.find("button.qual-cancel-edit").trigger("click");
                }
                else {
                    // Replace name input with text value
                    row.find("td.qual-name").text(row.find("td.qual-name input").val().trim());
                    // Replace result type dropdown with text value
                    row.find("td.qual-result-type").text(row.find("td.qual-result-type select").val());
                    // Hide edit action buttons and show standard action buttons
                    row.find("div.qual-edit-actions").addClass("hide");
                    row.find("div.qual-actions").removeClass("hide");
                }
                if (row.find("td.qual-result-type").text() === 'Single' 
                        && row.find("div.modal-params td.param-add-value select option[value='Submission ID']").length <= 0){
                    row.find("div.modal-params td.param-add-value select")
                       .prepend($("<option>", {value: "Submission ID"}).append("Submission ID"));
                }
                else if (row.find("td.qual-result-type").text() !== 'Single'){
                    if (row.find("div.modal-params td.param-add-value select option[value='Submission ID']").length > 0){
                        row.find("div.modal-params td.param-add-value select option[value='Submission ID']").remove();
                    }
                    row.find("div.modal-params td.param-name[data-param-name='Submission ID']").closest("tr").remove();
                    row.find("a.qualification-modal-link span.param-count").text(row.find("table#params-table tbody tr").length);
                }
            });
        }
        
        /**
         * Show notice if datastore form has been updated and config page is stale
         */
        if ($("button#update-datastore[data-datastore-slug]").length){
            // Check everytime window comes into focus
            $(window).on("focus", function(e){
                var datastoreSlug = $("button#update-datastore[data-datastore-slug]").data("datastore-slug");
                $.ajax({
                    method: "GET",
                    url: bundle.apiLocation() + "/kapps/" + bundle.kappSlug() + "/forms/" + datastoreSlug + "?include=fields",
                    dataType: "json",
                    contentType: "application/json",
                    success: function(data, textStatus, jqXHR){
                        var status = new Object();
                        var stale = false;
                        $.each(data.form.fields, function(i, field){
                            status[field.name] = !status[field.name]; 
                        });
                        $("table#column-table tbody td.column-name").each(function(){
                            status[$(this).text()] = !status[$(this).text()];
                        });
                        $.each(status, function(k, v){
                            if (v){
                                stale = true;
                            }
                        });
                        if (stale && $("div.content-main a.stale-fields").length <= 0){
                            $("div.content-main").prepend(
                                $("<a>", {href: "javascript:window.location.reload()", class: "stale-fields btn btn-info"}).append(
                                    $("<span>", {class: "fa fa-lg fa-refresh"}).html("&nbsp;"),
                                    $("<span>").text("This datastore's form has been updated. Click here to reload the page in order to see the latest fields.")
                                )
                            );
                        }
                        else if (!stale && $("div.content-main a.stale-fields").length > 0){
                            $("div.content-main a.stale-fields").remove();
                        }
                    }
                });
            });
        }
                
        /** END *** DATASTORE/CONFIG PAGE *** DOCUMENT READY CODE *********************************/
        
        
        /******************************************************************************************
         ** START *** DATASTORE/RECORD PAGE *** DOCUMENT READY CODE
         ** Loads a specific datastore subform for adding, cloning, or editing records.
         ******************************************************************************************/
        
        // Run below code only if div.datastore-record-container exists
        if ($("div.datastore-record-container").length){
            var recordContainer = $("div.datastore-record-container");
            recordContainer.on("click", "button.cancel-record", redirectToDatastore);
            
            var datastoreSlug = recordContainer.data("datastore-slug");
            var recordId = recordContainer.data("record-id");
            var cloneId = recordContainer.data("clone-id");
            var configuration = recordContainer.data('datastore-configuration');
            var uniqueConfiguration = typeof configuration === 'object' ? _.where(configuration, {unique: true}) : new Array();
            
            if (recordId){
                K.load({
                    path: bundle.spaceLocation() + "/submissions/" + recordId, 
                    container: recordContainer,
                    updated: redirectToDatastore,
                    loaded: function(form){
                        form.page().on('submit', {
                            execute: function(e, actions){
                                if ($.isEmptyObject(e.constraints) && uniqueConfiguration.length){
                                    actions.stop();
                                    checkDuplicateRecord(form, uniqueConfiguration, datastoreSlug, recordContainer, actions);
                                }
                            }
                        });
                    }
                });
            }
            else if (cloneId){
                $.ajax({
                    mathod: "GET",
                    url: bundle.apiLocation() + "/submissions/" + cloneId + "?include=values,form",
                    dataType: "json",
                    contentType: "application/json",
                    success: function(clone, textStatus, jqXHR){
                        K.load({
                            path: bundle.kappLocation() + "/" + datastoreSlug, 
                            container: recordContainer,
                            loaded: function(form){
                                if (form.submission().id() == null){
                                    if (clone.submission.form.name === form.name()){
                                        _.each(clone.submission.values, function(value, key){
                                            if (form.getFieldByName(key)){
                                                form.getFieldByName(key).value(value);
                                            }
                                        });
                                    }
                                }
                                form.page().on('submit', {
                                    execute: function(e, actions){
                                        if ($.isEmptyObject(e.constraints) && uniqueConfiguration.length){
                                            actions.stop();
                                            checkDuplicateRecord(form, uniqueConfiguration, datastoreSlug, recordContainer, actions);
                                        }
                                    }
                                });
                            },
                            created: redirectToDatastore
                        }); 
                    },
                    error: function(jqXHR, textStatus, errorThrown){
                        recordContainer.notifie({
                            message: "Failed to initialize clone of the record: " + errorThrown
                        });
                    }
                });
            }
            else {
                K.load({
                    path: bundle.kappLocation() + "/" + datastoreSlug, 
                    container: recordContainer,
                    created: redirectToDatastore,
                    loaded: function(form){
                        form.page().on('submit', {
                            execute: function(e, actions){
                                if ($.isEmptyObject(e.constraints) && uniqueConfiguration.length){
                                    actions.stop();
                                    checkDuplicateRecord(form, uniqueConfiguration, datastoreSlug, recordContainer, actions);
                                }
                            }
                        });
                    }
                });
            }
            
            /**
             * Overwrite the default field constraint violation error handler to use Notifie to display the errors above the individual fields.
             */
            bundle.config.renderers = {
                fieldConstraintViolations: function(form, fieldConstraintViolations) {
                    _.each(fieldConstraintViolations, function(value, key){
                        $(form.getFieldByName(key).wrapper()).notifie({
                            message: value.join("<br>"),
                            exitEvents: "click"
                        });
                    });
                }
            };
        }
        
        /** END *** DATASTORE/RECORD PAGE *** DOCUMENT READY CODE *********************************/
    });

    /*----------------------------------------------------------------------------------------------
     * COMMON INIALIZATION 
     *   This code is executed when the Javascript file is loaded
     *--------------------------------------------------------------------------------------------*/
    // Ensure the BUNDLE global object exists
    bundle = typeof bundle !== "undefined" ? bundle : {};
    // Create namespace for Admin Datastore
    bundle.adminDatastore = bundle.adminDatastore || {};
    // Create a scoped alias to simplify references to your namespace
    var datastore = bundle.adminDatastore;
    
    _.templateSettings = { interpolate: /\{\{(.+?)\}\}/g };

    /*----------------------------------------------------------------------------------------------
     * COMMON FUNCTIONS
     *--------------------------------------------------------------------------------------------*/
    
    /**********************************************************************************************
     ** START *** DATASTORE/CONFIG PAGE *** HELPER METHODS
     ** Allows for creating of new datastore forms and updating those forms.
     **********************************************************************************************/
    
    /**
     * Builds the JSON String of the Datastore Display Table Options to store as an Attribute.
     * 
     * @param table jQuery reference to the table which contains the Display Table Options
     * @return JSON String to be passed to the API as the attributes value
     */
    function buildDatastoreConfigurationAttribute(table) {
        var datastoreConfiguration = new Array();
        table.find("tbody tr").each(function(i, tr){
            datastoreConfiguration.push({
                data: $(tr).find("td.column-name").text(),
                title: $(tr).find("td.column-name").text(),
                visible: $(tr).find("td.column-visible input").prop("checked"),
                searchable: $(tr).find("td.column-searchable input").prop("checked"),
                orderable: $(tr).find("td.column-orderable input").prop("checked"),
                unique: $(tr).find("td.column-unique input").prop("checked")
            });
        });
        var attributes = [{
            name: "Datastore Configuration",
            values: [JSON.stringify(datastoreConfiguration)]
        }];
        return attributes;
    }
    
    function buildAttributeModelAjaxOptions(modelName, bridge, qualificationTable, form){
        // Create base option object for ajax
        var options = {
            dataType: "json",
            contentType: "application/json"
        };
        // Create base data object
        var data = {
            name: modelName,
            status: "Active",
            activeMappingName: modelName,
            mappings: [
                {
                    bridgeName: bridge.val() || "-",
                    name: modelName,
                    structure: "Submissions"
                }
            ],
            attributes: $.extend([], form.fields),
            qualifications: []
        };
        // Add Submission ID attribute
        data.attributes.push({
            name: "Submission ID"
        });
        
        // If Bridge Model exists, update it
        if (bridge.data("model-exists")){
            options.method = "put";
            options.url = bundle.apiLocation() + "/models/" + bridge.data("model-current-name");
        }
        // If it doesn't exist, create a new Model
        else {
            options.method = "post";
            options.url = bundle.apiLocation() + "/models";
        }
                
        // Add all qualifications
        qualificationTable.find("tbody tr.qualification-row").each(function(i, tr){
            var parameters = new Array();
            $(tr).find("td.qual-params table#params-table tbody tr").each(function(idx, trParam){
                if ($(trParam).find("td.param-value input").val().trim().length <= 0){
                    parameters.push({
                        name: $(trParam).find("td.param-name").text()
                    });
                }
            });
            data.qualifications.push({
                name: $(tr).find("td.qual-name").text(),
                resultType: $(tr).find("td.qual-result-type").text(),
                parameters: parameters
            });
        });
        
        // Add data to options
        options.data = JSON.stringify(data);
        
        return options;
    }
    
    function buildAttributeMappingAjaxOptions(modelMappingName, bridge, qualificationTable, form){
        // Create base option object for ajax
        var options = {
            method: "put",
            url: bundle.apiLocation() + "/models/" + modelMappingName + "/mappings/" + modelMappingName,
            dataType: "json",
            contentType: "application/json"
        };
        // Create base data object
        var data = {
            attributes: [],
            qualifications: []
        };
        
        _.each(form.fields, function(field){
            data.attributes.push({
                name: field.name,
                structureField: "${fields('values[" + field.name + "]')}"
            });
        });
        // Add Submission Id
        data.attributes.push({
            name: "Submission ID",
            structureField: "${fields('id')}"
        });
        
        // Add all qualifications with query
        qualificationTable.find("tbody tr.qualification-row").each(function(i, tr){
            var query = "kappSlug=" + bundle.kappSlug() + "&formSlug=" + form.slug + "&limit=1000";
            var isSingle = $(tr).find("td.qual-result-type").text() === "Single";
            // Submission ID can only be used for Single type qualifications and can not have kappSlug and formSlug in the query
            var submissionIdParam = isSingle ? $(tr).find("td.qual-params table#params-table tbody tr td.param-name[data-param-name='Submission ID']").text() : null;
            if (isSingle && $(tr).find("td.qual-params table#params-table tbody tr td.param-name[data-param-name='Submission ID']").length){
                var tdParamName = $(tr).find("td.qual-params table#params-table tbody tr td.param-name[data-param-name='Submission ID']");
                var paramValue = tdParamName.siblings("td.param-value").find("input").val().trim();
                query = "id=" + (paramValue.replace(/([\\])/g, "\\$1") || "${parameters('" + tdParamName.text() + "')}");
            }
            $(tr).find("td.qual-params table#params-table tbody tr").each(function(idx, trParam){
                var paramName = $(trParam).find("td.param-name").text();
                var paramValue = $(trParam).find("td.param-value input").val().trim();
                if (paramName !== "Submission ID"){
                    query += "&values[" + paramName + "]=" + (paramValue.replace(/([\\])/g, "\\$1") || "${parameters('" + paramName + "')}"); 
                }
            });
            data.qualifications.push({
                name: $(tr).find("td.qual-name").text(),
                query: query
            });
        });
        
        // Add data to options
        options.data = JSON.stringify(data);
        
        return options;
    }
    
    /** END *** DATASTORE/CONFIG PAGE *** HELPER METHODS ******************************************/
    
   
    /**********************************************************************************************
     ** START *** DATASTORE/RECORD PAGE *** HELPER METHODS
     ** Loads a specific datastore subform for adding, cloning, or editing records.
     **********************************************************************************************/
    
    /**
     * Check if duplicate record already exists
     */
    function checkDuplicateRecord(form, uniqueConfiguration, datastoreSlug, recordContainer, actions){
        var q = "";
        for (var i = 0; i < uniqueConfiguration.length; i++){
            var field = form.getFieldByName(uniqueConfiguration[i].data);
            if (field){
                if (q.length > 0){ q += " AND "; }
                q += "values[" + uniqueConfiguration[i].data + "] = "
                        + (field.value() && field.value().length 
                                ? "\"" + field.value().replace(/(["\\])/g, "\\$1") + "\"" 
                                : "null");
            }
            else {
                recordContainer.notifie({
                    message: "Failed to build query to check for duplicates. Please verify that the datastore configuration is correct."
                });
                return;
            }
        }
        $.ajax({
            mathod: "GET",
            url: bundle.apiLocation() + "/kapps/" + bundle.kappSlug() + "/forms/" + datastoreSlug + "/submissions?q=" + encodeURIComponent(q),
            dataType: "json",
            contentType: "application/json",
            success: function(result, textStatus, jqXHR){
                if (_.reject(result.submissions, {id: form.submission().id()}).length > 0){
                    recordContainer.notifie({
                        message: "Duplicate record already exists."
                    });
                }
                else {
                    actions.continue();
                }
            },
            error: function(jqXHR, textStatus, errorThrown){
                recordContainer.notifie({
                    message: "Failed to save due to error in duplicate check: " + errorThrown
                });
            }
        });
    }
    
    /**
     * Redirect back to the 
     */
    function redirectToDatastore(){
        location.href = $('a.return-to-store').attr('href');
    }
    
    /** END *** DATASTORE/RECORD PAGE *** HELPER METHODS ******************************************/
    
    /**********************************************************************************************
     ** START *** GLOBAL DATASTORE *** HELPER METHODS
     ** Helper functions used by multiple pages.
     **********************************************************************************************/
    
    datastore.checkFormForDuplicates = function(){
        return true;
    }
    
    /** END *** GLOBAL DATASTORE *** HELPER METHODS ***********************************************/
         
})($, _);