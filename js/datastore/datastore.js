/* JS Specific to the Datastore Console */
(function($, _) {
    /**********************************************************************************************
     * DOM MANIPULATION AND EVENT REGISTRATION
     *   This section is executed on page load to register events and otherwise manipulate the DOM.
     **********************************************************************************************/
    $(function() {
        
        /**
         * Event handler for creating a new datastore.
         */
        $("button#create_datastore").on("click", function(){
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
                name: form.find("input#datastore_name").val(),
                slug: form.find("input#datastore_slug").val(),
                description: form.find("textarea#datastore_description").val()
            };
            // Make ajax call to get json template for creating a new datastore form
            $.ajax({
                url: bundle.kappLocation() + "?partial=datastore/template.json",
                beforeSend: function(jqXHR, settings){
                    self.prop("disabled", true);
                },
                success: function(data, textStatus, jqXHR){
                    try {
                        // Make ajax call to create new form using json from above ajax call and form fields from the screen
                        $.ajax({
                            method: "POST",
                            url: bundle.apiLocation() + "/kapps/" + bundle.kappSlug() + "/forms",
                            dataType: "json",
                            data: JSON.stringify($.extend(true, JSON.parse(data), fieldData)),
                            contentType: "application/json",
                            success: function(data, textStatus, jqXHR){
                                // Redirect to update datastore page on success
                                location.href = bundle.kappLocation() + "/" + self.data("console-slug") + "?kapp=" + bundle.kappSlug() 
                                        + "&page=" + self.data("console-slug") + "/config&store=" + data.form.slug;
                            },
                            error: function(jqXHR, textStatus, errorThrown){
                                createError(JSON.parse(jqXHR.responseText).error);
                            },
                            complete: function(jqXHR, textStatus){
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
        $("form#create_datastore_form").on("keyup", "input#datastore_name", function(){
            $("input#datastore_slug").val($(this).val().trim().toLowerCase().replace(/[^a-z0-9\s-]/g, "").replace(/\s+/g, "-"));
        }).one("keyup", "input#datastore_slug", function(){
            console.log(this);
            $("form#create_datastore_form").off("keyup", "input#datastore_name");
        });
        
        /**
         * Event handler for updating a datastore.
         */
        $("button#update_datastore").on("click", function(){
            // Store instance to this button and form
            var self = $(this);
            var form = self.closest("form");
            // Get field data
            var fieldData = {
                name: form.find("input#datastore_name").val(),
                slug: form.find("input#datastore_slug").val(),
                description: form.find("textarea#datastore_description").val(),
                attributes: buildDatastoreConfigurationAttribute(form.find("table#column-table"))
            };
            // Make ajax call to update datastore with data from the form fields on the screen
            $.ajax({
                method: "PUT",
                url: bundle.apiLocation() + "/kapps/" + bundle.kappSlug() + "/forms/" + self.data("datastore-slug"),
                dataType: "json",
                data: JSON.stringify(fieldData),
                contentType: "application/json",
                beforeSend: function(jqXHR, settings){
                    self.prop("disabled", true);
                },
                success: function(data, textStatus, jqXHR){
                    // Reload page
                    location.href = bundle.kappLocation() + "/" + self.data("console-slug") + "?kapp=" + bundle.kappSlug() 
                            + "&page=" + self.data("console-slug") + "/config&store=" + data.form.slug;
                },
                error: function(jqXHR, textStatus, errorThrown){
                    self.notifie({
                        anchor: "form",
                        message: "Failed to update the datastore.<br>" + JSON.parse(jqXHR.responseText).error,
                        exitEvents: "click",
                        disable: false,
                        margin: {"margin-top":"10px", "margin-bottom":"10px"}
                    });
                },
                complete: function(jqXHR, textStatus){
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
        
        
        /**
         * Show submissions table
         */
        if ($("table#datastore-records-table").length){
            var consoleSlug = $("table#datastore-records-table").data("console-slug");
            var kappSlug = $("table#datastore-records-table").data("kapp-slug");
            var datastoreSlug = $("table#datastore-records-table").data("datastore-slug");
            
            loadDatastoreRecords(datastoreSlug);
            
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
                        var reader = new FileReader();
                        reader.onload = function(e){
                            processDatastoreRecordsImport($.csv.toObjects(e.target.result), datastoreSlug, importInput);
                        }
                        reader.readAsText(file);
                    }
                }
                importInput.val("");
            });
            
            $("table#datastore-records-table").on("click", "button.edit", function(e){
                var data = datastore.datastoreRecordsTable.row($(this).closest("tr")).data();
                location.href = bundle.kappLocation() + "/" + consoleSlug + "?kapp=" + kappSlug + "&page=datastore/record&store=" + datastoreSlug + "&id=" + data.ID;
            }).on("click", "button.clone", function(e){
                var data = datastore.datastoreRecordsTable.row($(this).closest("tr")).data();
                location.href = bundle.kappLocation() + "/" + consoleSlug + "?kapp=" + kappSlug + "&page=datastore/record&store=" + datastoreSlug + "&clone=" + data.ID;
            }).on("click", "button.delete", function(e){
                var self = $(this);
                var row = datastore.datastoreRecordsTable.row($(this).closest("tr"));
                var data = row.data();
                console.log(data);
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
                        console.log('success');
                        $.ajax({
                            url: bundle.apiLocation() + "/submissions/" + data.ID,
                            method: 'DELETE',
                            dataType: "json",
                            contentType: "application/json",
                            beforeSend: function(jqXHR, settings){
                                self.prop("disabled", true);
                            },
                            success: function(response, textStatus, jqXHR){
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
                confirmDelete.show();
                //$(confirmDelete.content()).find("button.btn-link").focus();
            });
        }
        
        if ($("div.datastore-record-container").length){
            var recordContainer = $("div.datastore-record-container");
            recordContainer.on("click", "button.cancel-record", redirectToDatastore);
            
            var datastoreSlug = recordContainer.data("datastore-slug");
            var recordId = recordContainer.data("record-id");
            var cloneId = recordContainer.data("clone-id");
            
            if (recordId){
                K.load({
                    path: bundle.spaceLocation() + "/submissions/" + recordId, 
                    container: recordContainer,
                    updated: redirectToDatastore
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
                                console.log("clone", clone);
                                console.log("form", form);
                                if (form.submission.id == null){
                                    if (clone.submission.form.name === form.name){
                                        _.each(clone.submission.values, function(value, key){
                                            if (form.fields[key]){
                                                form.fields[key].value(value);
                                            }
                                        });
                                    }
                                }
                            },
                            created: redirectToDatastore
                        }); 
                    },
                    error: function(jqXHR, textStatus, errorThrown){
                        recordContainer.notifie({
                            message: "Failed to initializa clone of the record: " + errorThrown
                        });
                    }
                });
            }
            else {
                K.load({
                    path: bundle.kappLocation() + "/" + datastoreSlug, 
                    container: recordContainer,
                    created: redirectToDatastore
                });                                
            }
        }
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
    
    function loadDatastoreRecords(datastoreSlug){
        $.ajax({
            mathod: "GET",
            url: bundle.kappLocation() + "?partial=" + "datastore/records.json&store=" + datastoreSlug,
            dataType: "json",
            contentType: "application/json",
            success: function(data, textStatus, jqXHR){
                records = $.extend(data, {
                    responsive: true,
                    pageLength: 25,
                    buttons: [
                        {
                            extend: "csv",
                            text: "Export CSV",
                            className: "btn-sm",
                            filename: $("table#datastore-records-table").data("datastore-name") + " Datastore",
                            exportOptions: {
                                modifier: {
                                    search: "none"
                                }
                            }
                        },
                        {
                            text: "Import CSV",
                            className: "btn-sm",
                            action: importDatastoreRecords
                        }
                    ]
                });
                $.each(records.columns, function( i, v){
                    v.visible = (v.visible === "true") ? true : false;
                    v.searchable = (v.searchable === "true") ? true : false;
                    v.orderable = (v.orderable === "true") ? true : false;
                });
                console.log(records);
                datastore.datastoreRecordsTable = $("table#datastore-records-table").DataTable(records);
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
                orderable: $(tr).find("td.column-orderable input").prop("checked")
            });
        });
        var attributes = [{
            name: "Datastore Configuration",
            values: [JSON.stringify(datastoreConfiguration)]
        }];
        return attributes;
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
        console.log(importData);
        /** Retrieve all fields in the datastore **/
        $.ajax({
            method: 'GET',
            url: bundle.apiLocation() + "/kapps/" + bundle.kappSlug() + "/forms/" + datastoreSlug + "?include=fields",
            dataType: "json",
            contentType: "application/json",
            success: function(data, textStatus, jqXHR){
                /** Convert fields to a map to check if file has valid headers **/
                var fieldMap = $.extend(_.object(_.map(data.form.fields, function(field){
                    console.log(field);
                    return [field.name, true];
                })), {"Datastore Record ID": true, "": true});
                console.log(fieldMap);
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
            console.log("new", row);
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
                    statusCounters.failedRows.push($.extend(row, {"Datastore Record ID": ""}));
                    statusCounters.createErrors++;
                    statusCounters.processedRows++;
                    calculateDatastoreRecordsImportResults(statusCounters, importInput, datastoreSlug);
                }
            });
        }
        else {
            // Update record
            console.log("update", row);
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
                    statusCounters.failedRows.push($.extend(row, {"Datastore Record ID": datastoreRecordID}));
                    statusCounters.updateErrors++;
                    statusCounters.processedRows++;
                    calculateDatastoreRecordsImportResults(statusCounters, importInput, datastoreSlug);
                }
            });
        }
    }
    
    /**
     * Check if all ajax calls have completed.
     * If they have, show results.  
     * 
     * @param statusCounters
     * @param importInput
     * @param datastoreSlug
     */
    function calculateDatastoreRecordsImportResults(statusCounters, importInput, datastoreSlug){
        if (statusCounters.processedRows == statusCounters.totalRows){
            var msg = $("<div>");
            msg.append($("<div>").append(statusCounters.processedRows + " records were processed."));
            if (statusCounters.createdRows > 0){
                msg.append($("<div>").append(statusCounters.createdRows + " records were created successfully."));
            }
            if (statusCounters.createErrors > 0){
                msg.append($("<div>").append(statusCounters.createErrors + " records failed to save."));
            }
            if (statusCounters.updatedRows > 0){
                msg.append($("<div>").append(statusCounters.updatedRows + " records were updated successfully."));
            }
            if (statusCounters.updateErrors > 0){
                msg.append($("<div>").append(statusCounters.updateErrors + " records failed to update."));
            }
            if (statusCounters.failedRows.length > 0){
                var failuresContainer = $("<div>").addClass("hide").appendTo(msg);
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
                console.log(failures);
                var failureTable = table.DataTable(failures);
                window.zzz = failureTable;
                msg.append($("<div>").addClass("pull-right").append(failureTable.buttons().container()));
            }
            importInput.closest("div.datastore-records-table-buttons").notifie({
                severity: "info",
                anchor: "h3",
                message: msg,
                onShow: function(){
                    $(".export-failures").trigger("click");
                }
            });
            loadDatastoreRecords(datastoreSlug);
        }
    }
    
    function redirectToDatastore(){
        location.href = $('a.return-to-store').attr('href');
    }
     
})($, _);