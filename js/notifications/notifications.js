/* JS Specific to the Notifications Console */
(function($, _) {

    /*----------------------------------------------------------------------------------------------
     * COMMON INIALIZATION 
     *   This code is executed when the Javascript file is loaded
     *--------------------------------------------------------------------------------------------*/
    // Ensure the BUNDLE global object exists
    bundle = typeof bundle !== "undefined" ? bundle : {};
    // Create namespace for Admin Notifications
    bundle.notifications = bundle.notifications || {};
    // Create a scoped alias to simplify references to your namespace
    var notifications = bundle.notifications;

    // Private namespace for notifications
    var adminNote = {
        console: {},
        form: {}
    };

    // Instanciate Variables Used on the Form Page
    adminNote.form.textElData = null;
    adminNote.form.kappDetails = null;
    adminNote.form.formDetails = null;
    
    _.templateSettings = { interpolate: /\{\{(.+?)\}\}/g };


    /*----------------------------------------------------------------------------------------------
     * DOM MANIPULATION AND EVENT REGISTRATION 
     *   This section is executed on page load to register events and otherwise manipulate the DOM.
     *--------------------------------------------------------------------------------------------*/

    $(function() {     

        /******************************************************************************************
         ** START *** NOTIFICATIONS/CONSOLE & SNIPPETS PAGE *** DOCUMENT READY CODE
         ** Displays the stored notifications.
         ******************************************************************************************/
        
        // Run below code only if table#table-notifications exists
        if ($("table#table-notifications").length){
            adminNote.console.slug = $("table#table-notifications").data("console-slug");
            adminNote.console.kappSlug = $("table#table-notifications").data("kapp-slug");
            adminNote.console.datastoreSlug = $("table#table-notifications").data("datastore-slug");
            adminNote.console.filters = $("table#table-notifications").data("query");
            adminNote.console.type = $("table#table-notifications").data("type");
            
            /**
             * Load the records for the current store
             */
            adminNote.console.loadDatastoreRecords(adminNote.console.datastoreSlug, adminNote.console.filters, adminNote.console.type);
            
            /**
             * Add functionality for importing CSV files
             */
            $("input#notification-import").on("change", function(e){
                var importInput = $(this);
                // Get files from file input
                var fileList = importInput.prop("files");
                // If file uploaded
                if (fileList.length > 0){
                    // Get first file
                    var file = fileList.item(0);
                    // If not CSV file
                    if (file.name && file.name.slice(-4).toLowerCase() !== ".csv"){
                        importInput.closest("div.table-notifications-buttons").notifie({
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
                            adminNote.console.processDatastoreRecordsImport($.csv.toObjects(e.target.result), adminNote.console.datastoreSlug, importInput);
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
            $("table#table-notifications").on("click", "button.delete", function(e){
                // On click of delete button, confirm that the user is sure they want to delete
                var self = $(this);
                // Get selected row data
                var row = notifications.datastoreRecordsTable.row($(this).closest("tr"));
                var data = row.data();
                // Build confirmation dialog
                var confirmDelete = new KD.Modal({
                    header: "Confirm Delete",
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

        /******************************************************************************************
         ** END *** NOTIFICATIONS/CONSOLE & SNIPPETS PAGE *** DOCUMENT READY CODE
         ** Displays the stored notifications.
         ******************************************************************************************/


        /******************************************************************************************
         ** START *** NOTIFICATIONS/RECORD PAGE *** DOCUMENT READY CODE
         ** Loads a specific notification subform for adding, cloning, or editing records.
         ******************************************************************************************/
        
        // Run below code only if div.notification-record-container exists
        if ($("div.notification-record-container").length){
            var recordContainer = $("div.notification-record-container");
            recordContainer.on("click", "button.cancel-record", adminNote.console.redirectToNotifications);
            // Set Flag so that replacement variables get built on page load, but not rebuilt on submit
            adminNote.form.hasReplacementsBuilt = false;
            
            var notificationDataSlug = "notification-data";
            var recordId = recordContainer.data("record-id");
            var cloneId = recordContainer.data("clone-id");
            var type = recordContainer.data("type");
            var configuration = recordContainer.data('datastore-configuration');
            var uniqueConfiguration = typeof configuration === 'object' ? _.where(configuration, {unique: true}) : new Array();
            
            if (recordId){
                K.load({
                    path: bundle.spaceLocation() + "/submissions/" + recordId, 
                    container: recordContainer,
                    updated: adminNote.console.redirectToNotifications,
                    loaded: function(form){
                        adminNote.form.initialize();
                        adminNote.form.buildLocaleSelector(form);
                        form.page().on('submit', {
                            execute: function(e, actions){
                                if ($.isEmptyObject(e.constraints) && uniqueConfiguration.length){
                                    actions.stop();
                                    adminNote.form.checkDuplicateRecord(form, uniqueConfiguration, notificationDataSlug, recordContainer, actions);
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
                            path: bundle.kappLocation() + "/" + notificationDataSlug, 
                            container: recordContainer,
                            loaded: function(form){
                                adminNote.form.initialize();
                                adminNote.form.buildLocaleSelector(form);
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
                                            adminNote.form.checkDuplicateRecord(form, uniqueConfiguration, notificationDataSlug, recordContainer, actions);
                                        }
                                    }
                                });
                            },
                            created: adminNote.console.redirectToNotifications
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
                    path: bundle.kappLocation() + "/" + notificationDataSlug, 
                    container: recordContainer,
                    created: adminNote.console.redirectToNotifications,
                    loaded: function(form){
                        adminNote.form.initialize();
                        adminNote.form.buildLocaleSelector(form);
                        form.select('field[Type]').value(type);
                        form.page().on('submit', {
                            execute: function(e, actions){
                                if ($.isEmptyObject(e.constraints) && uniqueConfiguration.length){
                                    actions.stop();
                                    adminNote.form.checkDuplicateRecord(form, uniqueConfiguration, notificationDataSlug, recordContainer, actions);
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
    });

    /** END *** DOCUMENT READY CODE *********************************/


    /*----------------------------------------------------------------------------------------------
     * START NOTIFICATIONS CONSOLE / SNIPPET PAGE FUNCTIONS
    *--------------------------------------------------------------------------------------------*/

    /**
     * Loads the records for the current datastore and displays them in a DataTable
     * 
     * @param datastoreSlug Slug of datastore from which to fetch records.
     */
    adminNote.console.loadDatastoreRecords = function(datastoreSlug, filters, type){
        // Ajax call to get the records
        $.ajax({
            mathod: "GET",
            url: bundle.kappLocation() + "?partial=" + "notifications/records.json&store=" + datastoreSlug + "&" +  filters + "&type=" + type,
            dataType: "json",
            contentType: "application/json",
            success: function(data, textStatus, jqXHR){
                // Set up DataTable configuration object with export/import buttons
                records = $.extend(data, {
                    responsive: true,
                    pageLength: 25,
                    stateSave: true,
                    buttons: [
                        {
                            extend: "csv",
                            text: "Export CSV",
                            filename: "Notification " + $("table#table-notifications").data("type") + "s",
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
                            action: adminNote.console.importDatastoreRecords
                        }
                    ]
                });
                // Add Column Renderers
                bundle.admin.addDataTableRenderers(records.columns, {
                    actionButtons: function ( d, type, row ){
                        return "<div class=\"btn-group notification-btns\">" +
                            "<a href=\"" + bundle.kappLocation() + "/" + bundle.notifications.consoleSlug + 
                                "?page=notifications/record&type=" + bundle.notifications.type + "&id=" + row.ID + 
                                "\" class=\"btn btn-xs btn-default edit\" title=\"Edit\"><span class=\"fa fa-pencil fa-fw\"></span></a>" +
                            "<a href=\"" + bundle.kappLocation() + "/" + bundle.notifications.consoleSlug + 
                                "?page=notifications/record&type=" + bundle.notifications.type + "&clone=" + row.ID + 
                                "\" class=\"btn btn-xs btn-success clone\" title=\"Clone\"><span class=\"fa fa-clone fa-fw\"></span></a>" +
                            "<button class=\"btn btn-xs btn-danger delete\" title=\"Delete\"><span class=\"fa fa-times fa-fw\"></span></button>" +
                        "</div>";
                    }
                });
                // Build DataTable
                notifications.datastoreRecordsTable = $("table#table-notifications").DataTable(records);
                // Append the import/export buttons to the buttons section on the page
                notifications.datastoreRecordsTable.buttons().nodes().each(function(){
                    $("div.notification-table-buttons").prepend($(this).attr("href", "#")).prepend("\n");
                });
            },
            error: function(jqXHR, textStatus, errorThrown){
                $("table#table-notifications").empty().notifie({
                    message: "Failed to load Notification " + $("table#table-notifications").data("type") + "s.<br>" + errorThrown
                });
            }
        });
    }
    
    /**
     * If browser supports File API, begin import process. Otherwise throw error.
     */
    adminNote.console.importDatastoreRecords = function(){
        // Check if File API is available
        if (window.File && window.FileReader && window.FileList) {
            $("input#notification-import").trigger("click");
        }
        else {
            $("div.table-notifications-buttons").notifie({
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
    adminNote.console.processDatastoreRecordsImport = function(importData, datastoreSlug, importInput){
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
                })), {"ID": true, "": true});
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
                    importInput.closest("div.table-notifications-buttons").notifie({
                        anchor: "h3",
                        message: "Invalid CSV file. " 
                            + invalidHeaders.length + " of the headers in the CSV file do not match an existing notification field. <br/>"
                            + "Invalid headers: " + invalidHeaders.join(", "),
                        exitEvents: "mouseup"
                    });
                }
                /** If headers are valid, process import **/
                else {
                    // Clear and destroy table and show notification that import is happening
                    notifications.datastoreRecordsTable.destroy();
                    $("table#table-notifications").empty()
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
                            adminNote.console.processSingleDatastoreRecord(row, datastoreSlug, importInput, statusCounters);
                        });
                    }, 0);
                }
            },
            error: function(jqXHR, textStatus, errorThrown){
                importInput.closest("div.table-notifications-buttons").notifie({
                    anchor: "h3",
                    message: "An error occurred while importing records: " + errorThrown,
                    exitEvents: "mouseup"
                });
            }
        });
    }
    
    /**
     * Save a single row of data.
     * Update the row if ID is passed in, otherwise create a new row.
     *  
     * @param row Data to save.
     * @param datastoreSlug Slug of datastore into which this data should be saved.
     * @param importInput jQuery instance of file input element.
     * @param statusCounters Object for keeping track of multiple ajax calls.
     */
    adminNote.console.processSingleDatastoreRecord = function(row, datastoreSlug, importInput, statusCounters){
        // Variable to store Record ID if doing an update
        var datastoreRecordID = false;
        // If ID property exists, save it if it's not empty, and remove from row object
        if (row.hasOwnProperty("ID")){
            if (row["ID"] != null && row["ID"].trim().length > 0){
                datastoreRecordID = row["ID"];
            }
            // Delete since we are passing the row as the data to the API and this is not a real field
            delete row["ID"];
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
                    adminNote.console.calculateDatastoreRecordsImportResults(statusCounters, importInput, datastoreSlug);
                },
                error: function(jqXHR, textStatus, errorThrown){
                    statusCounters.failedRows.push($.extend(row, {"ID": "", "ERROR": errorThrown}));
                    statusCounters.createErrors++;
                    statusCounters.processedRows++;
                    adminNote.console.calculateDatastoreRecordsImportResults(statusCounters, importInput, datastoreSlug);
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
                    adminNote.console.calculateDatastoreRecordsImportResults(statusCounters, importInput, datastoreSlug);
                },
                error: function(jqXHR, textStatus, errorThrown){
                    statusCounters.failedRows.push($.extend(row, {"ID": datastoreRecordID, "ERROR": errorThrown}));
                    statusCounters.updateErrors++;
                    statusCounters.processedRows++;
                    adminNote.console.calculateDatastoreRecordsImportResults(statusCounters, importInput, datastoreSlug);
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
    adminNote.console.calculateDatastoreRecordsImportResults = function(statusCounters, importInput, datastoreSlug){
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
                var table = $("<table>").addClass("table table-hover table-bordered dt-responsive nowrap").appendTo(failuresContainer);
                var failures = {
                    columns: _.map(_.keys(statusCounters.failedRows[0]), function(key){return {title: key, data: key};}),
                    data: statusCounters.failedRows,
                    dom: 'B',
                    buttons: [
                        {
                            extend: "csv",
                            text: "Export CSV of Failed Rows",
                            className: "export-failures",
                            filename: $("table#table-notifications").data("datastore-name") + " Notifications - Failed Import Rows",
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
            importInput.closest("div.table-notifications-buttons").notifie({
                severity: statusCounters.failedRows.length > 0 ? "danger" : "info",
                anchor: "h3",
                message: msg
            });
            adminNote.console.loadDatastoreRecords(datastoreSlug, adminNote.console.filters, adminNote.console.type);
        }
    }

    /*----------------------------------------------------------------------------------------------
     * END NOTIFICATIONS CONSOLE / SNIPPET PAGE FUNCTIONS
    *--------------------------------------------------------------------------------------------*/


    /*----------------------------------------------------------------------------------------------
     * START NOTIFICATIONS FORM PAGE FUNCTIONS
    *--------------------------------------------------------------------------------------------*/


    adminNote.form.initialize = function() {
        if (adminNote.form.hasReplacementsBuilt === false) {
            //populate the kappsDynamicMenu - Bridge not used to not clutter up the bridge list with 'internal use' functions.
            adminNote.form.getSpaceAttributes();
            adminNote.form.getAllKapps();
            adminNote.form.getDateFormats();
            adminNote.form.getSnippets();
            adminNote.form.rebindClickEventToSelectionMenu();
            
            //Bind event to the textarea elements on the page (Subject, Message Body, and Text Message Body)
            //May want to add a class or custom data attribute to these to make this more selective in the event other elements ever get added.
            $('textarea[data-allows-replacement]').on("focusout", function(e) {
                adminNote.form.textElData = {
                    "id":$(this).attr('id'),
                    "startingPosition":$(this).prop('selectionStart'),
                    "endingPosition":$(this).prop('selectionEnd')
                };
            })

            //Bind an event to all text area and input nodes to clear the adminNote.form.textElData variable, otherwise inadvertent replacement can be inserted.
            $('textarea:not([data-allows-replacement]), input').on("focusout", function() {
                adminNote.form.textElData = null;
            })

            //Bind an event to replacement button to hide the appearance warning message
            $('#dynamicDropdownMenu').on('click',function() {
                $('.appearance-alert').fadeOut();
            })

        }
        // Reset Flag so that when the subform is submitted and the initialize function is called again
        // replacements are not rebuilt 
        adminNote.form.hasReplacementsBuilt = true;
    }

    // Function for getting Space Attributes
    adminNote.form.getSpaceAttributes = function(){
        K.api("GET",bundle.spaceLocation() + "/app/api/v1/space?include=attributes",{"complete":function(data){adminNote.form.populateSpaceAttributes(data)}})
    }
    
    // Function for getting Kapps Attributes
    adminNote.form.getAllKapps = function(){
        K.api("GET",bundle.spaceLocation() + "/app/api/v1/kapps?include=attributes",{"complete":function(data){adminNote.form.populateKappList(data)}})
    }
  
    // Function for getting Date Formats
    adminNote.form.getDateFormats = function(){
        K.api("GET",bundle.spaceLocation() + "/app/api/v1/kapps/" + bundle.kappSlug() + "/forms/notification-template-dates/submissions?include=details,values&limit=999&q=values[Status]=\"active\"",{"complete":function(data){adminNote.form.populateAppearanceOptions(data)}})
    }

    // Function for getting Snippets to Include
    adminNote.form.getSnippets = function(){
        K.api("GET",bundle.spaceLocation() + "/app/api/v1/kapps/" + bundle.kappSlug() + "/forms/notification-data/submissions?include=details,values&limit=999&q=values[Type]=\"Snippet\"",{"complete":function(data){adminNote.form.populateSnippetOptions(data)}})
    }

    // Function for getting forms in a kapp
    adminNote.form.getAllKappForms = function(kappSlug) {
        K.api("GET",bundle.spaceLocation() + "/app/api/v1/kapps/" + kappSlug + "/forms?include=attributes,fields",{"complete":function(data){adminNote.form.populateFormList(data)}})
    }

    // Function for populating Space Attributes
    adminNote.form.populateSpaceAttributes = function(data){
        var spaceAttributes = JSON.parse(data["responseText"])["space"]["attributes"];
        $('ul.dropdown-menu[data-menu-name="Space Attributes"]').empty();
        $.each(spaceAttributes,function(iterator,value) {
            $('ul.dropdown-menu[data-menu-name="Space Attributes"]').append('<li><a class="dynamic-replacement" tabindex="-1" href="#">spaceAttributes(\'' + value['name'] + '\')</a></li>')
        });
        adminNote.form.rebindClickEventToSelectionMenu();
    }

    // Function for populating Apperance Options
    adminNote.form.populateAppearanceOptions = function(data){
        var dateSubmissions = JSON.parse(data["responseText"])['submissions'];
        $('ul.dropdown-menu[data-menu-name="Appearance Attributes"]').empty();
        if (dateSubmissions.length > 0) {
            $.each(dateSubmissions,function(iterator,value) {
                $('ul.dropdown-menu[data-menu-name="Appearance Attributes"]').append('<li><a class="dynamic-replacement dynamic-appearance" tabindex="-1" href="#">appearance(\':: date field here ::${format(\'' + value['values']['Name'] + '\')}\')</a></li>');
            });
            $('ul.dropdown-menu[data-menu-name="Appearance Attributes"]').append('<li class="disabled"><a class="dynamic-replacement-noaction" href="#">Enter additional formats in the Datastore form <button id="notification-dates-button" data-element-type="button" data-button-type="custom" class="btn btn-link">Notification Dates</button> </a></li>');
            $('ul.dropdown-menu a.dynamic-replacement-noaction').on('click',function(e) {
                e.preventDefault();
            });
        } else {
            $('ul.dropdown-menu[data-menu-name="Appearance Attributes"]').append('<li class="disabled"><a class="dynamic-replacement-noaction" href="#">No Date Format have been defined.<br>Enter formats in the Datastore form <button id="notification-dates-button" data-element-type="button" data-button-type="custom" class="btn btn-link">Notification Dates</button> </a></li>');
            $('ul.dropdown-menu a.dynamic-replacement-noaction').on('click',function(e) {
                e.preventDefault();
            });
        }
        $('#notification-dates-button').on('click',function(e) {
            window.open(bundle.spaceLocation() + '/' + bundle.kappSlug() + '/datastore?kapp=admin&page=datastore/store&store=notification-template-dates', '_blank');
        });
        //bind event to newly added items
        adminNote.form.rebindClickEventToSelectionMenu();
    }

    // Function for populating Apperance Options
    adminNote.form.populateSnippetOptions = function(data){
        var submissions = JSON.parse(data["responseText"])['submissions'];
        $('ul.dropdown-menu[data-menu-name="Snippets"]').empty();
        if (submissions.length > 0) {
            $.each(submissions,function(iterator,value) {
                $('ul.dropdown-menu[data-menu-name="Snippets"]').append('<li><a class="dynamic-replacement" tabindex="-1" href="#">snippet(\'' + value['values']['Name'] + '\')</a></li>');
            });
            $('ul.dropdown-menu[data-menu-name="Snippets"]').append('<li class="disabled"><a class="dynamic-replacement-noaction" href="#">Create reusable snippets here: <button id="notification-snippets-button" data-element-type="button" data-button-type="custom" class="btn btn-link">Notification Snippets</button> </a></li>');
            $('ul.dropdown-menu a.dynamic-replacement-noaction').on('click',function(e) {
                e.preventDefault();
            });
        } else {
            $('ul.dropdown-menu[data-menu-name="Snippets"]').append('<li class="disabled"><a class="dynamic-replacement-noaction" href="#">No Snippets have been created.<br>Create reusable snippets here: <button id="notification-snippets-button" data-element-type="button" data-button-type="custom" class="btn btn-link">Notification Snippets</button> </a></li>');
            $('ul.dropdown-menu a.dynamic-replacement-noaction').on('click',function(e) {
                e.preventDefault();
            });
        }
        $('#notification-snippets-button').on('click',function(e) {
            window.open(bundle.spaceLocation() + '/' + bundle.kappSlug() + '/notifications?page=notifications/snippets&type=Snippet', '_blank');
        });
        //bind event to newly added items
        adminNote.form.rebindClickEventToSelectionMenu();
    }

    // Function for populating Kapp List
    adminNote.form.populateKappList = function(data){
        adminNote.form.kappDetails = JSON.parse(data["responseText"]);
        var kappArray = adminNote.form.kappDetails["kapps"];
        $('#kappSelectionList').append("<option></option>");
        $.each(kappArray,function(i,val) {
            $('#kappSelectionList').append("<option value='" + val["slug"] + "'>" + val["name"] + "</option>");
        })
        $('#kappSelectionList').change(function() {
            var selectedKapp = $(this).val();
            if ($(this).val() != null && $(this).val() != "" ) {
                adminNote.form.getAllKappForms($(this).val());
                //Populate KAPP attributes
                $.each(adminNote.form.kappDetails["kapps"],function(i,val) {
                    if (val["slug"] === selectedKapp) {
                        //find proper dropdown menu, then empty and repopulate
                        $('ul.dropdown-menu[data-menu-name="Kapp Attributes"]').empty();
                        $.each(val["attributes"],function(iterator,value) {
                            $('ul.dropdown-menu[data-menu-name="Kapp Attributes"]').append('<li><a class="dynamic-replacement" tabindex="-1" href="#">kappAttributes(\'' + value['name'] + '\')</a></li>')
                        })
                        //bind event to newly added items
                        adminNote.form.rebindClickEventToSelectionMenu();
                    }
                });
            } else {
                $('#kappFormSelectionList').val("");
                $('#kappFormSelectionList').empty();
                $('ul.dropdown-menu[data-menu-name="Kapp Attributes"]').empty();
                $('ul.dropdown-menu[data-menu-name="Kapp Attributes"]').append('<li><a class="dynamic-replacement" tabindex="-1" href="#">kappAttributes(\'Replace with attribute name\')</a></li>');
                $('ul.dropdown-menu[data-menu-name="Form Attributes"]').empty();
                $('ul.dropdown-menu[data-menu-name="Form Attributes"]').append('<li><a class="dynamic-replacement" tabindex="-1" href="#">formAttributes(\'Replace with attribute name\')</a></li>');
                $('ul.dropdown-menu[data-menu-name="Submission Values"]').empty();
                $('ul.dropdown-menu[data-menu-name="Submission Values"]').append('<li><a class="dynamic-replacement" tabindex="-1" href="#">values(\'Replace with form field name\')</a></li>');
                //bind event to newly added items
                adminNote.form.rebindClickEventToSelectionMenu();
            }
        });
    }

    // Function for populating the form list
    adminNote.form.populateFormList = function(data){
        adminNote.form.formDetails = JSON.parse(data["responseText"]);
        var formArray = adminNote.form.formDetails["forms"];
        $('#kappFormSelectionList').empty();
        $('#kappFormSelectionList').append("<option></option>");
        $.each(formArray,function(i,val) {
            $('#kappFormSelectionList').append("<option value='" + val["slug"] + "'>" + val["name"] + "</option>");
        })
      
        $('#kappFormSelectionList').change(function() {
            var selectedForm = $(this).val();
            if ($(this).val() != null && $(this).val() != "" ) {
                $.each(adminNote.form.formDetails["forms"],function(i,val) {
                    if (val["slug"] === selectedForm) {
                        //find proper dropdown menu for form attributes, then empty and repopulate
                        $('ul.dropdown-menu[data-menu-name="Form Attributes"]').empty();
                        $.each(val["attributes"],function(iterator,value) {
                          $('ul.dropdown-menu[data-menu-name="Form Attributes"]').append('<li><a class="dynamic-replacement" tabindex="-1" href="#">formAttributes(\'' + value['name'] + '\')</a></li>')
                        })
                        //bind event to newly added items
                        adminNote.form.rebindClickEventToSelectionMenu();

                        //find proper dropdown menu for submission attributes, then empty and repopulate
                        $('ul.dropdown-menu[data-menu-name="Submission Values"]').empty();
                        $.each(val["fields"],function(iterator,value) {
                          //What to do with the second ones--they should not have the tabindex=-1 thing....
                          $('ul.dropdown-menu[data-menu-name="Submission Values"]').append('<li><a class="dynamic-replacement" tabindex="-1" href="#">values(\'' + value['name'] + '\')</a></li>')
                        })
                        //bind event to newly added items
                        adminNote.form.rebindClickEventToSelectionMenu();
                    }
                })
            } else {
                $('ul.dropdown-menu[data-menu-name="Form Attributes"]').empty();
                $('ul.dropdown-menu[data-menu-name="Form Attributes"]').append('<li><a class="dynamic-replacement" tabindex="-1" href="#">formAttributes(\'Replace with attribute name\')</a></li>');
                $('ul.dropdown-menu[data-menu-name="Submission Values"]').empty();
                $('ul.dropdown-menu[data-menu-name="Submission Values"]').append('<li><a class="dynamic-replacement" tabindex="-1" href="#">values(\'Replace with form field name\')</a></li>');
                adminNote.form.rebindClickEventToSelectionMenu();
            }
        });
    }
  
    // Function for inserting text at Caret
    adminNote.form.insertTextAtCaret = function(elPosition,replacementText) {
        if (typeof elPosition != 'undefined' && elPosition != null) {
            replacementText = "${" + replacementText + "}";
            var v = $('#' + elPosition["id"]).val();
            var textBefore = v.substring(0,  elPosition["startingPosition"] );
            var textAfter  = v.substring( elPosition["endingPosition"], v.length );
            var newCursorPos = elPosition["startingPosition"] + replacementText.length;
            if (replacementText.indexOf("appearance") < 0 ){
                $('#' + elPosition["id"]).val( textBefore + replacementText + textAfter );
            } else {
                var textInbetween = v.substring(elPosition["startingPosition"],elPosition["endingPosition"])
                //Warn if selected data doesn't start with dollar sign and end with right curly brace
                if ((textInbetween.indexOf("$") != 0) || textInbetween.slice(-1) != "}"){
                    $('.appearance-alert-message').text("Be sure to select the entire replacement field before selecting an appearance option.  Ex: ${values('Requested Date')}");
                    $('.appearance-alert').fadeIn();
                return;
            }
            var replacementParts = replacementText.split("::");
            $('#' + elPosition["id"]).val( textBefore + replacementParts[0] + textInbetween + replacementParts[2] + textAfter );
                newCursorPos = elPosition["startingPosition"] + replacementParts[0].length + textInbetween.length + replacementParts[2] + 6;
            }
            var newCursorPos = elPosition["startingPosition"] + replacementText.length;
            $('#' + elPosition["id"]).prop('selectionStart',newCursorPos);
            $('#' + elPosition["id"]).prop('selectionEnd',newCursorPos);
            $('#' + elPosition["id"]).focus();
        }
    }
  
    // Function for rebinding click events to the selection menu
    adminNote.form.rebindClickEventToSelectionMenu = function() {
        //Bind event to the dynamic-replacement <a> in the dropdown list tags.
        $('ul.dropdown-menu a.dynamic-replacement').off("click");
        $('ul.dropdown-menu a.dynamic-replacement').on("click", function(e) {
            e.preventDefault();
            adminNote.form.insertTextAtCaret(adminNote.form.textElData,$(this).text());
        });
    }

    // Build Locale Selector Dropdown from hidden dom element on Form.jsp
    adminNote.form.buildLocaleSelector = function(form) {
        $localOptions = $('div select#temp-locales').children();
        if ( $(form.select('field[Language]') !== null) ) {
            $languageSelector = $(form.select('field[Language]').element())
            currentValue = form.select('field[Language]').value();
            $languageSelector.html($localOptions)
            if (K('submission') !== null){
                $languageSelector.val(K('submission').value("Language"));
            }
        }
    }   
    

    /**
     * Check if duplicate record already exists
     */
    adminNote.form.checkDuplicateRecord = function(form, uniqueConfiguration, datastoreSlug, recordContainer, actions){
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
    adminNote.console.redirectToNotifications = function(){
        location.href = $('a.return-to-notifications').attr('href');
    }

    /*----------------------------------------------------------------------------------------------
     * END NOTIFICATIONS FORM PAGE FUNCTIONS
    *--------------------------------------------------------------------------------------------*/
         
})($, _);