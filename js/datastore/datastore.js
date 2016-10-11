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
            window.localStorage.removeItem("DataTables_datastore-records-table_" + window.location.pathname);
        }
        
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
                description: form.find("textarea#datastore-description").val()
            };
            
            /** Make ajax call to get json template for creating a new datastore form **/
            $.ajax({
                url: bundle.kappLocation() + "?partial=datastore/template.json",
                beforeSend: function(jqXHR, settings){
                    self.prop("disabled", true);
                },
                success: function(data, textStatus, jqXHR){
                    try {
                        /** Make ajax call to create new form using json from above ajax call and form fields from the screen **/
                        $.ajax({
                            method: "POST",
                            url: bundle.apiLocation() + "/kapps/" + bundle.kappSlug() + "/forms?include=fields",
                            dataType: "json",
                            data: JSON.stringify($.extend(true, JSON.parse(data), fieldData)),
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
                                                                header: "<h3>Error</h3>",
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
                                                    header: "<h3>Error</h3>",
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
                                                    header: "<h3>Error</h3>",
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
                                        header: "<h3>Error</h3>",
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
             * Event handler for parameters link which builds and destroys the modal, keeping the data hidden in the dom.
             */
            $("table#qualification-table").on("click", "a.qualification-modal-link", function(e){
                var modalParams = $(this).siblings('div.modal-params');
                var modalBody = $("<div>");
                // Build confirmation dialog
                var parameterModal = new KD.Modal({
                    header: "<h3>Bridge Parameters</h3>",
                    body: function(element, actions) {
                        // Move parameters table from body (where it's hidden) to the modal
                        modalBody.append(modalParams.children())
                            // Append to element
                            .appendTo(element)
                            // Event handler for delete parameter button
                            .on("click", "td.param-actions button.param-delete", function(e){
                                $(this).closest("tr").remove();
                            })
                            // Event handler for add parameter button
                            .on("click", "td.param-add-btn button", function(e){
                                // Get new parameter name
                                var paramName = $(this).closest("tr").find("td.param-add-value select").val();
                                // If parameter doesn't already exist, add it
                                if (modalBody.find("table#params-table td.param-name[data-param-name=\""+paramName+"\"]").length <= 0){
                                    modalBody.find("table#params-table tbody").append($("<tr>")
                                            .append($("<td>", {class: "param-name", "data-param-name": paramName}).text(paramName))
                                            .append($("<td>", {class: "param-actions"})
                                                    .append($("<div>", {class: "btn-group pull-right"})
                                                            .append($("<button>", {type: "button", class: "btn btn-xs btn-danger param-delete"})
                                                                    .append($("<span>", {class: "fa fa-times fa-fw"}))))));
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
                    header: "<h3>Confirm Delete</h3>",
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
            });
        }
                
        /** END *** DATASTORE/CONFIG PAGE *** DOCUMENT READY CODE *********************************/
        
        /******************************************************************************************
         ** START *** DATASTORE/STORE PAGE *** DOCUMENT READY CODE
         ** Displays the stored records.
         ******************************************************************************************/
        
        // Run below code only if table#datastore-records-table exists
        if ($("table#datastore-records-table").length){
            var consoleSlug = $("table#datastore-records-table").data("console-slug");
            var kappSlug = $("table#datastore-records-table").data("kapp-slug");
            var datastoreSlug = $("table#datastore-records-table").data("datastore-slug");
            
            /**
             * Load the records for the current store
             */
            loadDatastoreRecords(datastoreSlug);
            
            /**
             * Add functionality for importing CSV files
             */
            $("input#datastore-records-import").on("change", function(e){
                var importInput = $(this);
                // Get files from file input
                var fileList = importInput.prop("files");
                // If file uploaded
                if (fileList.length > 0){
                    // Get first file
                    var file = fileList.item(0);
                    // If not CSV file
                    if (file.name && file.name.slice(-4).toLowerCase() !== ".csv"){
                        importInput.closest("div.datastore-records-table-buttons").notifie({
                            anchor: "h3",
                            message: "Invalid file (" + file.name + "). Only files of type CSV are allowed.",
                            exitEvents: "mouseup"
                        });
                    }
                    else {
                        // Initialize FileReader
                        var reader = new FileReader();
                        // Setup onload function which will process the import
                        reader.onload = function(e){
                            processDatastoreRecordsImport($.csv.toObjects(e.target.result), datastoreSlug, importInput);
                        }
                        // Read file
                        reader.readAsText(file);
                    }
                }
                // Reset file input value to empty string to allow on change  to fire on the same file if needed
                importInput.val("");
            });
            
            /**
             * Event handlers for edit, clone, and delete buttons for the records table
             */
            $("table#datastore-records-table").on("click", "button.edit", function(e){
                // On click of edit button, send user to record page for editing current row
                var data = datastore.datastoreRecordsTable.row($(this).closest("tr")).data();
                location.href = bundle.kappLocation() + "/" + consoleSlug + "?page=datastore/record&store=" + datastoreSlug + "&id=" + data.ID;
            }).on("click", "button.clone", function(e){
                // On click of edit button, send user to record page for cloning current row
                var data = datastore.datastoreRecordsTable.row($(this).closest("tr")).data();
                location.href = bundle.kappLocation() + "/" + consoleSlug + "?page=datastore/record&store=" + datastoreSlug + "&clone=" + data.ID;
            }).on("click", "button.delete", function(e){
                // On click of delete button, confirm that the user is sure they want to delete
                var self = $(this);
                // Get selected row data
                var row = datastore.datastoreRecordsTable.row($(this).closest("tr"));
                var data = row.data();
                // Build confirmation dialog
                var confirmDelete = new KD.Modal({
                    header: "<h3>Confirm Delete</h3>",
                    body: "Are you sure you want to delete this record?",
                    footer: function(element, actions) {
                        element.addClass("text-right").append(
                            $("<button>", {class: "btn btn-success", tabindex: 2}).text("Yes").on("click", actions.accept),
                            $("<button>", {class: "btn btn-link", tabindex: 1}).text("Cancel").on("click", actions.dismiss)
                        );
                    },
                    size: "sm",
                    backdrop: true,
                    backdropclose: true,
                    keyboardclose: true,
                    renderCallback: false,
                    accept: function(){
                        // On acceptance of confirmation dialog, call api to delete record
                        $.ajax({
                            url: bundle.apiLocation() + "/submissions/" + data.ID,
                            method: 'DELETE',
                            dataType: "json",
                            contentType: "application/json",
                            beforeSend: function(jqXHR, settings){
                                self.prop("disabled", true);
                            },
                            success: function(response, textStatus, jqXHR){
                                // Remove row and redraw table on success
                                row.remove().draw();
                            },
                            error: function(jqXHR, textStatus, errorThrown){
                                self.notifie({
                                    anchor: "table",
                                    message: "An error occurred while deleting the record: " + errorThrown
                                });
                            }
                       });
                    }
                });
                // Show confirmation dialog
                confirmDelete.show();
                // Blur delete button
                $(this).blur();
            });
        }
        
        /** END *** DATASTORE/STORE PAGE *** DOCUMENT READY CODE *********************************/
        
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
            bundle.config = {
                renderers: {
                    fieldConstraintViolations: function(form, fieldConstraintViolations) {
                        _.each(fieldConstraintViolations, function(value, key){
                            $(form.getFieldByName(key).wrapper()).notifie({
                                message: value.join("<br>"),
                                exitEvents: "click"
                            });
                        });
                    }
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
                parameters.push({
                    name: $(trParam).find("td.param-name").text()
                });
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
            var query = "kappSlug=" + bundle.kappSlug() + "&formSlug=" + form.slug + "&limit=999";
            $(tr).find("td.qual-params table#params-table tbody tr").each(function(idx, trParam){
                var paramName = $(trParam).find("td.param-name").text();
                if (paramName !== "Submission ID"){
                    query += "&values[" + paramName + "]=${parameters('" + paramName + "')}";
                }
                else {
                    query += "&id=${parameters('" + paramName + "')}";
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
     ** START *** DATASTORE/STORE PAGE *** HELPER METHODS
     ** Displays the stored records.
     **********************************************************************************************/
    
    /**
     * Loads the records for the current datastore and displays them in a DataTable
     * 
     * @param datastoreSlug Slug of datastore from which to fetch records.
     */
    function loadDatastoreRecords(datastoreSlug){
        // Ajax call to get the records
        $.ajax({
            mathod: "GET",
            url: bundle.kappLocation() + "?partial=" + "datastore/records.json&store=" + datastoreSlug,
            dataType: "json",
            contentType: "application/json",
            success: function(data, textStatus, jqXHR){
                // Set up DataTable configuration object with export/import buttons
                console.log(data);
                records = $.extend(data, {
                    responsive: true,
                    pageLength: 25,
                    stateSave: true,
                    buttons: [
                        {
                            extend: "csv",
                            text: "Export CSV",
                            className: "btn-sm",
                            filename: $("table#datastore-records-table").data("datastore-name") + " Datastore",
                            exportOptions: {
                                modifier: {
                                    search: "none"
                                },
                                columns: ":not(.ignore-export)",
                                orthogonal: "export"
                            }
                        },
                        {
                            text: "Import CSV",
                            className: "btn-sm",
                            action: importDatastoreRecords
                        }
                    ]
                });
                $.each(records.columns, function(i, col){
                    switch(col.renderType){
                        case "date":
                            col.render = $.fn.dataTable.render.moment("date", "ll", bundle.config.userLocale);
                            break;
                        case "datetime":
                            col.render = $.fn.dataTable.render.moment("datetime", "lll", bundle.config.userLocale);
                            break;
                        case "time":
                            col.render = $.fn.dataTable.render.moment("time", "LT", bundle.config.userLocale);
                            break;
                        case "checkbox":
                            col.render = $.fn.dataTable.render.checkbox();
                            break;
                        case "attachment":
                            col.render = $.fn.dataTable.render.attachment(col.data);
                            break;
                        case "text":
                        case "dropdown":
                        case "radio":
                            col.render = $.fn.dataTable.render.text();
                            break;
                    }
                });
                // Build DataTable
                datastore.datastoreRecordsTable = $("table#datastore-records-table").DataTable(records);
                // Append the import/export buttons to the buttons section on the page
                datastore.datastoreRecordsTable.buttons().nodes().each(function(){
                    $("div.datastore-records-table-buttons").prepend($(this).attr("href", "#")).prepend("\n");
                });
            },
            error: function(jqXHR, textStatus, errorThrown){
                $("table#datastore-records-table").empty().notifie({
                    message: "Failed to load records for the datastore.<br>" + errorThrown
                });
            }
        });
    }
    
    /**
     * If browser supports File API, begin import process. Otherwise throw error.
     */
    function importDatastoreRecords(){
        // Check if File API is available
        if (window.File && window.FileReader && window.FileList) {
            $("input#datastore-records-import").trigger("click");
        }
        else {
            $("div.datastore-records-table-buttons").notifie({
                anchor: "h3",
                message: "Your browser does not support the import feature. Please use a newer browser."
            });
        }
    }
    
    /**
     * Save each row of data as a submission for the given Datastore.
     * 
     * @param importData Array of Objects to be saved.
     * @param datastoreSlug Slug of datastore into which this data should be imported.
     * @param importInput jQuery instance of file input element.
     */
    function processDatastoreRecordsImport(importData, datastoreSlug, importInput){
        /** Retrieve all fields in the datastore **/
        $.ajax({
            method: 'GET',
            url: bundle.apiLocation() + "/kapps/" + bundle.kappSlug() + "/forms/" + datastoreSlug + "?include=fields",
            dataType: "json",
            contentType: "application/json",
            success: function(data, textStatus, jqXHR){
                /** Convert fields to a map to check if file has valid headers **/
                var fieldMap = $.extend(_.object(_.map(data.form.fields, function(field){
                    return [field.name, true];
                })), {"Datastore Record ID": true, "": true});
                // Create array to store invalid headers
                var invalidHeaders = new Array();
                // Get first row (any row can be used since headers are the keys of the row object)
                var headerRow = importData[0];
                // For each row, check if all passed in headers match existing fields
                _.each(headerRow, function(val, key){
                    // If field doesn't exist, save field in invalidHeaders array
                    if (!fieldMap[key]){ 
                        invalidHeaders.push(key);
                    }
                });
                
                /** If invalid headers found, throw error **/
                if (invalidHeaders.length){
                    importInput.closest("div.datastore-records-table-buttons").notifie({
                        anchor: "h3",
                        message: "Invalid CSV file. " 
                            + invalidHeaders.length + " of the headers in the CSV file do not match an existing field on this datastore. <br/>"
                            + "Invalid headers: " + invalidHeaders.join(", "),
                        exitEvents: "mouseup"
                    });
                }
                /** If headers are valid, process import **/
                else {
                    // Clear and destroy table and show notification that import is happening
                    bundle.adminDatastore.datastoreRecordsTable.destroy();
                    $("table#datastore-records-table").empty()
                        .append($("<tr>")
                            .append($("<td>").addClass("alert alert-info")
                                .append($("<span>").addClass("fa fa-cog fa-spin"))
                                .append(" Importing records")));
                    
                    // Create counters to keep track of when ajax calls complete
                    var statusCounters = {
                        totalRows: importData.length,
                        processedRows: 0,
                        createdRows: 0,
                        createErrors: 0,
                        updatedRows: 0,
                        updateErrors: 0,
                        failedRows: new Array()
                    };
                    
                    // Iterate through each row in the imported csv. Delay with set timeout to allow for loader to be rendered.
                    window.setTimeout(function(){
                        _.each(importData, function(row){
                            processSingleDatastoreRecord(row, datastoreSlug, importInput, statusCounters);
                        });
                    }, 0);
                }
            },
            error: function(jqXHR, textStatus, errorThrown){
                importInput.closest("div.datastore-records-table-buttons").notifie({
                    anchor: "h3",
                    message: "An error occurred while importing records: " + errorThrown,
                    exitEvents: "mouseup"
                });
            }
        });
    }
    
    /**
     * Save a single row of data.
     * Update the row if Datastore Record ID is passed in, otherwise create a new row.
     *  
     * @param row Data to save.
     * @param datastoreSlug Slug of datastore into which this data should be saved.
     * @param importInput jQuery instance of file input element.
     * @param statusCounters Object for keeping track of multiple ajax calls.
     */
    function processSingleDatastoreRecord(row, datastoreSlug, importInput, statusCounters){
        // Variable to store Record ID if doing an update
        var datastoreRecordID = false;
        // If Datastore Record ID property exists, save it if it's not empty, and remove from row object
        if (row.hasOwnProperty("Datastore Record ID")){
            if (row["Datastore Record ID"] != null && row["Datastore Record ID"].trim().length > 0){
                datastoreRecordID = row["Datastore Record ID"];
            }
            // Delete since we are passing the row as the data to the API and this is not a real field
            delete row["Datastore Record ID"];
        }
        // Remove any empty title rows (which are generated in the export due to the buttons column)
        if (row.hasOwnProperty("")){
            delete row[""];
        }
        // If Submission ID doesn't exist, create a new record
        if (!datastoreRecordID){
            // Create new record
            $.ajax({
                method: "POST",
                url: bundle.apiLocation() + "/kapps/" + bundle.kappSlug() + "/forms/" + datastoreSlug + "/submissions",
                dataType: "json",
                data: JSON.stringify({values: row}),
                contentType: "application/json",
                success: function(data, textStatus, jqXHR){
                    statusCounters.createdRows++;
                    statusCounters.processedRows++;
                    calculateDatastoreRecordsImportResults(statusCounters, importInput, datastoreSlug);
                },
                error: function(jqXHR, textStatus, errorThrown){
                    statusCounters.failedRows.push($.extend(row, {"Datastore Record ID": "", "ERROR": errorThrown}));
                    statusCounters.createErrors++;
                    statusCounters.processedRows++;
                    calculateDatastoreRecordsImportResults(statusCounters, importInput, datastoreSlug);
                }
            });
        }
        else {
            // Update record
            $.ajax({
                method: "PUT",
                url: bundle.apiLocation() + "/submissions/" + datastoreRecordID,
                dataType: "json",
                data: JSON.stringify({values: row}),
                contentType: "application/json",
                success: function(data, textStatus, jqXHR){
                    statusCounters.updatedRows++;
                    statusCounters.processedRows++;
                    calculateDatastoreRecordsImportResults(statusCounters, importInput, datastoreSlug);
                },
                error: function(jqXHR, textStatus, errorThrown){
                    statusCounters.failedRows.push($.extend(row, {"Datastore Record ID": datastoreRecordID, "ERROR": errorThrown}));
                    statusCounters.updateErrors++;
                    statusCounters.processedRows++;
                    calculateDatastoreRecordsImportResults(statusCounters, importInput, datastoreSlug);
                }
            });
        }
    }
    
    /**
     * Check if all ajax calls for import have completed.
     * If they have, show results.  
     * 
     * @param statusCounters
     * @param importInput
     * @param datastoreSlug
     */
    function calculateDatastoreRecordsImportResults(statusCounters, importInput, datastoreSlug){
        if (statusCounters.processedRows == statusCounters.totalRows){
            var msg = $("<div>");
            msg.append($("<div>").append($("<span>", {class: "fa fa-fw"}))
                    .append(statusCounters.processedRows + " records were processed."));
            if (statusCounters.createdRows > 0){
                msg.append($("<div>").append($("<span>", {class: "fa fa-check fa-fw"}))
                        .append(statusCounters.createdRows + " records were created successfully."));
            }
            if (statusCounters.createErrors > 0){
                msg.append($("<div>").append($("<span>", {class: "fa fa-times fa-fw"}))
                        .append(statusCounters.createErrors + " records failed to save."));
            }
            if (statusCounters.updatedRows > 0){
                msg.append($("<div>").append($("<span>", {class: "fa fa-check fa-fw"}))
                        .append(statusCounters.updatedRows + " records were updated successfully."));
            }
            if (statusCounters.updateErrors > 0){
                msg.append($("<div>", {class: "strong"}).append($("<span>", {class: "fa fa-times fa-fw"}))
                        .append(statusCounters.updateErrors + " records failed to update."));
            }
            if (statusCounters.failedRows.length > 0){
                var failuresContainer = $("<div>", {class: "import-has-errors hide"}).appendTo(msg);
                var table = $("<table>").addClass("table table-hover table-striped table-bordered dt-responsive nowrap").appendTo(failuresContainer);
                var failures = {
                    columns: _.map(_.keys(statusCounters.failedRows[0]), function(key){return {title: key, data: key};}),
                    data: statusCounters.failedRows,
                    dom: 'B',
                    buttons: [
                        {
                            extend: "csv",
                            text: "Export CSV of Failed Rows",
                            className: "btn-sm export-failures",
                            filename: $("table#datastore-records-table").data("datastore-name") + " Datastore - Failed Import Rows",
                            exportOptions: {
                                modifier: {
                                    search: "none"
                                }
                            }
                        }
                    ]
                };
                var failureTable = table.DataTable(failures);
                msg.append($("<div>").addClass("pull-right").append(failureTable.buttons().container()));
            }
            importInput.closest("div.datastore-records-table-buttons").notifie({
                severity: statusCounters.failedRows.length > 0 ? "danger" : "info",
                anchor: "h3",
                message: msg
            });
            loadDatastoreRecords(datastoreSlug);
        }
    }
    
    /** END *** DATASTORE/STORE PAGE *** HELPER METHODS ******************************************/
    
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
                                ? "\"" + field.value() + "\"" 
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
            url: bundle.apiLocation() + "/kapps/" + bundle.kappSlug() + "/forms/" + datastoreSlug + "/submissions?q=" + q,
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