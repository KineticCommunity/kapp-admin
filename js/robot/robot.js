/* JS Specific to the Robot Console */
(function($, _) {
    /*----------------------------------------------------------------------------------------------
     * DOM MANIPULATION AND EVENT REGISTRATION 
     *   This section is executed on page load to register events and otherwise manipulate the DOM.
     *--------------------------------------------------------------------------------------------*/
    $(function() {
        
        /******************************************************************************************
         ** START *** ROBOT/CONFIG PAGE *** DOCUMENT READY CODE
         ** Allows for creating of new robot forms and updating those forms.
         ******************************************************************************************/
        
        /**
         * Event handler for creating a new robot.
         */
        $("button#create-robot").on("click", function(){
            // Store instance to this button and form
            var self = $(this);
            var form = self.closest("form");
            // Function for displaying errors
            var createError = function(e){
                self.notifie({
                    anchor: "form",
                    message: "Failed to create a new robot.<br>" + e,
                    exitEvents: "click",
                    disable: false,
                    margin: {"margin-bottom":"10px"}
                });
            }
            // Get field data
            var fieldData = {
                name: form.find("input#robot-name").val(),
                slug: form.find("input#robot-slug").val(),
                description: form.find("textarea#robot-description").val()
            };
            
            /** Make ajax call to get json template for creating a new robot form **/
            $.ajax({
                url: bundle.kappLocation() + "?partial=robot/template.json",
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
                                var redirectUrl = bundle.kappLocation() + "/" + self.data("console-slug") + "?kapp=" + bundle.kappSlug() 
                                        + "&page=" + self.data("console-slug") + "/config&robot=" + data.form.slug;
                                // Redirect to update robot page on success
                                location.href = redirectUrl;
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
         * Event handlers for mirroring name field input into slug when creating robot.
         */
        $("form#create-robot-form").on("keyup", "input#robot-name", function(){
            $("input#robot-slug").val($(this).val().trim().toLowerCase().replace(/[^a-z0-9\s-]/g, "").replace(/\s+/g, "-"));
        }).one("keyup", "input#robot-slug", function(){
            $("form#create-robot-form").off("keyup", "input#robot-name");
        });
        
        /**
         * Event handler for updating a robot.
         */
        $("button#update-robot").on("click", function(){
            // Store instance to this button and form
            var self = $(this);
            var form = self.closest("form");
            // Get field data
            var fieldData = {
                name: form.find("input#robot-name").val(),
                slug: form.find("input#robot-slug").val(),
                description: form.find("textarea#robot-description").val(),
                attributes: buildRobotConfigurationAttribute(form.find("table#column-table"))
            };

            /** Make ajax call to update robot with data from the form fields on the screen **/
            $.ajax({
                method: "PUT",
                url: bundle.apiLocation() + "/kapps/" + bundle.kappSlug() + "/forms/" + self.data("robot-slug") + "?include=fields",
                dataType: "json",
                data: JSON.stringify(fieldData),
                contentType: "application/json",
                beforeSend: function(jqXHR, settings){
                    self.prop("disabled", true);
                },
                success: function(data, textStatus, jqXHR){
                    // Define url so we can reload
                    var reloadUrl = bundle.kappLocation() + "/" + self.data("console-slug") + "?kapp=" + bundle.kappSlug() 
                            + "&page=" + self.data("console-slug") + "/config&robot=" + data.form.slug;
                    // Reload page on success
                    location.href = reloadUrl;
                },
                error: function(jqXHR, textStatus, errorThrown){
                    self.notifie({
                        anchor: "form",
                        message: "Failed to update the robot.<br>" + JSON.parse(jqXHR.responseText).error,
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
        
        /** END *** ROBOT/CONFIG PAGE *** DOCUMENT READY CODE *********************************/
        
        /******************************************************************************************
         ** START *** ROBOT/ROBOT PAGE *** DOCUMENT READY CODE
         ** Displays the stored records.
         ******************************************************************************************/
        
        // Run below code only if table#robot-records-table exists
        if ($("table#robot-records-table").length){
            var consoleSlug = $("table#robot-records-table").data("console-slug");
            var kappSlug = $("table#robot-records-table").data("kapp-slug");
            var robotSlug = $("table#robot-records-table").data("robot-slug");
            
            /**
             * Load the records for the current robot
             */
            loadRobotRecords(robotSlug);
            
            /**
             * Add functionality for importing CSV files
             */
            $("input#robot-records-import").on("change", function(e){
                var importInput = $(this);
                // Get files from file input
                var fileList = importInput.prop("files");
                // If file uploaded
                if (fileList.length > 0){
                    // Get first file
                    var file = fileList.item(0);
                    // If not CSV file
                    if (file.name && file.name.slice(-4).toLowerCase() !== ".csv"){
                        importInput.closest("div.robot-records-table-buttons").notifie({
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
                            processRobotRecordsImport($.csv.toObjects(e.target.result), robotSlug, importInput);
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
            $("table#robot-records-table").on("click", "button.edit", function(e){
                // On click of edit button, send user to record page for editing current row
                var data = robot.robotRecordsTable.row($(this).closest("tr")).data();
                location.href = bundle.kappLocation() + "/" + consoleSlug + "?kapp=" + kappSlug + "&page=robot/record&robot=" + robotSlug + "&id=" + data.ID;
            }).on("click", "button.clone", function(e){
                // On click of edit button, send user to record page for cloning current row
                var data = robot.robotRecordsTable.row($(this).closest("tr")).data();
                location.href = bundle.kappLocation() + "/" + consoleSlug + "?kapp=" + kappSlug + "&page=robot/record&robot=" + robotSlug + "&clone=" + data.ID;
            }).on("click", "button.delete", function(e){
                // On click of delete button, confirm that the user is sure they want to delete
                var self = $(this);
                // Get selected row data
                var row = robot.robotRecordsTable.row($(this).closest("tr"));
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
        
        /** END *** ROBOT/ROBOT PAGE *** DOCUMENT READY CODE *********************************/
        
        /******************************************************************************************
         ** START *** ROBOT/RECORD PAGE *** DOCUMENT READY CODE
         ** Loads a specific robot subform for adding, cloning, or editing records.
         ******************************************************************************************/
        
        // Run below code only if div.robot-record-container exists
        if ($("div.robot-record-container").length){
            var recordContainer = $("div.robot-record-container");
            recordContainer.on("click", "button.cancel-record", redirectToRobot);
            
            var robotSlug = recordContainer.data("robot-slug");
            var recordId = recordContainer.data("record-id");
            var cloneId = recordContainer.data("clone-id");
            
            if (recordId){
                K.load({
                    path: bundle.spaceLocation() + "/submissions/" + recordId, 
                    container: recordContainer,
                    updated: redirectToRobot
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
                            path: bundle.kappLocation() + "/" + robotSlug, 
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
                            },
                            created: redirectToRobot
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
                    path: bundle.kappLocation() + "/" + robotSlug, 
                    container: recordContainer,
                    created: redirectToRobot,
                    loaded: function(form){
//                        console.log("FORM",form);
//                        console.log("FORM",form.page());
                          // TODO Implement unique check before save
//                        form.page().on('submit', {
//                            execute: function(e, actions){
//                                console.log("SUBMITTING",e,e.constraints,actions);
//                            }
//                        });
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
        
        /** END *** ROBOT/RECORD PAGE *** DOCUMENT READY CODE *********************************/
    });

    /*----------------------------------------------------------------------------------------------
     * COMMON INIALIZATION 
     *   This code is executed when the Javascript file is loaded
     *--------------------------------------------------------------------------------------------*/
    // Ensure the BUNDLE global object exists
    bundle = typeof bundle !== "undefined" ? bundle : {};
    // Create namespace for Admin Robot
    bundle.adminRobot = bundle.adminRobot || {};
    // Create a scoped alias to simplify references to your namespace
    var robot = bundle.adminRobot;

    /*----------------------------------------------------------------------------------------------
     * COMMON FUNCTIONS
     *--------------------------------------------------------------------------------------------*/
    
    /**********************************************************************************************
     ** START *** ROBOT/CONFIG PAGE *** HELPER METHODS
     ** Allows for creating of new robot forms and updating those forms.
     **********************************************************************************************/
    
    /**
     * Builds the JSON String of the Robot Display Table Options to store as an Attribute.
     * 
     * @param table jQuery reference to the table which contains the Display Table Options
     * @return JSON String to be passed to the API as the attributes value
     */
    function buildRobotConfigurationAttribute(table) {
        var robotConfiguration = new Array();
        table.find("tbody tr").each(function(i, tr){
            robotConfiguration.push({
                data: $(tr).find("td.column-name").text(),
                title: $(tr).find("td.column-name").text(),
                visible: $(tr).find("td.column-visible input").prop("checked"),
                searchable: $(tr).find("td.column-searchable input").prop("checked"),
                orderable: $(tr).find("td.column-orderable input").prop("checked")//,
                //unique: $(tr).find("td.column-unique input").prop("checked") TODO uncomment when unique is implemented
            });
        });
        var attributes = [{
            name: "Robot Configuration",
            values: [JSON.stringify(robotConfiguration)]
        }];
        return attributes;
    }
    
    /** END *** ROBOT/CONFIG PAGE *** HELPER METHODS ******************************************/
    
    /**********************************************************************************************
     ** START *** ROBOT/ROBOT PAGE *** HELPER METHODS
     ** Displays the stored records.
     **********************************************************************************************/
    
    /**
     * Loads the records for the current robot and displays them in a DataTable
     * 
     * @param robotSlug Slug of robot from which to fetch records.
     */
    function loadRobotRecords(robotSlug){
        // Ajax call to get the records
        $.ajax({
            mathod: "GET",
            url: bundle.kappLocation() + "?partial=" + "robot/records.json&robot=" + robotSlug,
            dataType: "json",
            contentType: "application/json",
            success: function(data, textStatus, jqXHR){
                // Set up DataTable configuration object with export/import buttons
                records = $.extend(data, {
                    responsive: true,
                    pageLength: 25,
                    buttons: [
                        {
                            extend: "csv",
                            text: "Export CSV",
                            className: "btn-sm",
                            filename: $("table#robot-records-table").data("robot-name") + " Robot",
                            exportOptions: {
                                modifier: {
                                    search: "none"
                                }
                            }
                        },
                        {
                            text: "Import CSV",
                            className: "btn-sm",
                            action: importRobotRecords
                        }
                    ]
                });
                // Go through the list of column objects and change all values that should be booleans from strings to booleans
                $.each(records.columns, function( i, v){
                    v.visible = (v.visible === "true") ? true : false;
                    v.searchable = (v.searchable === "true") ? true : false;
                    v.orderable = (v.orderable === "true") ? true : false;
                    //v.unique = (v.unique === "true") ? true : false; TODO uncomment when unique is implemented
                });
                console.log(records);
                // Build DataTable
                robot.robotRecordsTable = $("table#robot-records-table").DataTable(records);
                // Append the import/export buttons to the buttons section on the page
                robot.robotRecordsTable.buttons().nodes().each(function(){
                    $("div.robot-records-table-buttons").prepend($(this).attr("href", "#")).prepend("\n");
                });
            },
            error: function(jqXHR, textStatus, errorThrown){
                $("table#robot-records-table").empty().notifie({
                    message: "Failed to load records for the robot.<br>" + errorThrown
                });
            }
        });
    }
    
    /**
     * If browser supports File API, begin import process. Otherwise throw error.
     */
    function importRobotRecords(){
        // Check if File API is available
        if (window.File && window.FileReader && window.FileList) {
            $("input#robot-records-import").trigger("click");
        }
        else {
            $("div.robot-records-table-buttons").notifie({
                anchor: "h3",
                message: "Your browser does not support the import feature. Please use a newer browser."
            });
        }
    }
    
    /**
     * Save each row of data as a submission for the given Robot.
     * 
     * @param importData Array of Objects to be saved.
     * @param robotSlug Slug of robot into which this data should be imported.
     * @param importInput jQuery instance of file input element.
     */
    function processRobotRecordsImport(importData, robotSlug, importInput){
        /** Retrieve all fields in the robot **/
        $.ajax({
            method: 'GET',
            url: bundle.apiLocation() + "/kapps/" + bundle.kappSlug() + "/forms/" + robotSlug + "?include=fields",
            dataType: "json",
            contentType: "application/json",
            success: function(data, textStatus, jqXHR){
                /** Convert fields to a map to check if file has valid headers **/
                var fieldMap = $.extend(_.object(_.map(data.form.fields, function(field){
                    return [field.name, true];
                })), {"Robot Record ID": true, "": true});
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
                    importInput.closest("div.robot-records-table-buttons").notifie({
                        anchor: "h3",
                        message: "Invalid CSV file. " 
                            + invalidHeaders.length + " of the headers in the CSV file do not match an existing field on this robot. <br/>"
                            + "Invalid headers: " + invalidHeaders.join(", "),
                        exitEvents: "mouseup"
                    });
                }
                /** If headers are valid, process import **/
                else {
                    // Clear and destroy table and show notification that import is happening
                    bundle.adminRobot.robotRecordsTable.destroy();
                    $("table#robot-records-table").empty()
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
                            processSingleRobotRecord(row, robotSlug, importInput, statusCounters);
                        });
                    }, 0);
                }
            },
            error: function(jqXHR, textStatus, errorThrown){
                importInput.closest("div.robot-records-table-buttons").notifie({
                    anchor: "h3",
                    message: "An error occurred while importing records: " + errorThrown,
                    exitEvents: "mouseup"
                });
            }
        });
    }
    
    /**
     * Save a single row of data.
     * Update the row if Robot Record ID is passed in, otherwise create a new row.
     *  
     * @param row Data to save.
     * @param robotSlug Slug of robot into which this data should be saved.
     * @param importInput jQuery instance of file input element.
     * @param statusCounters Object for keeping track of multiple ajax calls.
     */
    function processSingleRobotRecord(row, robotSlug, importInput, statusCounters){
        // Variable to store Record ID if doing an update
        var robotRecordID = false;
        // If Robot Record ID property exists, save it if it's not empty, and remove from row object
        if (row.hasOwnProperty("Robot Record ID")){
            if (row["Robot Record ID"] != null && row["Robot Record ID"].trim().length > 0){
                robotRecordID = row["Robot Record ID"];
            }
            // Delete since we are passing the row as the data to the API and this is not a real field
            delete row["Robot Record ID"];
        }
        // Remove any empty title rows (which are generated in the export due to the buttons column)
        if (row.hasOwnProperty("")){
            delete row[""];
        }
        // If Submission ID doesn't exist, create a new record
        if (!robotRecordID){
            // Create new record
            $.ajax({
                method: "POST",
                url: bundle.apiLocation() + "/kapps/" + bundle.kappSlug() + "/forms/" + robotSlug + "/submissions",
                dataType: "json",
                data: JSON.stringify({values: row}),
                contentType: "application/json",
                success: function(data, textStatus, jqXHR){
                    statusCounters.createdRows++;
                    statusCounters.processedRows++;
                    calculateRobotRecordsImportResults(statusCounters, importInput, robotSlug);
                },
                error: function(jqXHR, textStatus, errorThrown){
                    statusCounters.failedRows.push($.extend(row, {"Robot Record ID": "", "ERROR": errorThrown}));
                    statusCounters.createErrors++;
                    statusCounters.processedRows++;
                    calculateRobotRecordsImportResults(statusCounters, importInput, robotSlug);
                }
            });
        }
        else {
            // Update record
            $.ajax({
                method: "PUT",
                url: bundle.apiLocation() + "/submissions/" + robotRecordID,
                dataType: "json",
                data: JSON.stringify({values: row}),
                contentType: "application/json",
                success: function(data, textStatus, jqXHR){
                    statusCounters.updatedRows++;
                    statusCounters.processedRows++;
                    calculateRobotRecordsImportResults(statusCounters, importInput, robotSlug);
                },
                error: function(jqXHR, textStatus, errorThrown){
                    statusCounters.failedRows.push($.extend(row, {"Robot Record ID": robotRecordID, "ERROR": errorThrown}));
                    statusCounters.updateErrors++;
                    statusCounters.processedRows++;
                    calculateRobotRecordsImportResults(statusCounters, importInput, robotSlug);
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
     * @param robotSlug
     */
    function calculateRobotRecordsImportResults(statusCounters, importInput, robotSlug){
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
                            filename: $("table#robot-records-table").data("robot-name") + " Robot - Failed Import Rows",
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
            importInput.closest("div.robot-records-table-buttons").notifie({
                severity: statusCounters.failedRows.length > 0 ? "danger" : "info",
                anchor: "h3",
                message: msg
            });
            loadRobotRecords(robotSlug);
        }
    }
    
    /** END *** ROBOT/ROBOT PAGE *** HELPER METHODS ******************************************/
    
    /**********************************************************************************************
     ** START *** ROBOT/RECORD PAGE *** HELPER METHODS
     ** Loads a specific robot subform for adding, cloning, or editing records.
     **********************************************************************************************/
    
    /**
     * Redirect back to the 
     */
    function redirectToRobot(){
        location.href = $('a.return-to-robot').attr('href');
    }
    
    /** END *** ROBOT/RECORD PAGE *** HELPER METHODS ******************************************/
    
    /**********************************************************************************************
     ** START *** GLOBAL ROBOT *** HELPER METHODS
     ** Helper functions used by multiple pages.
     **********************************************************************************************/
    
    robot.checkFormForDuplicates = function(){
        return true;
    }
    
    /** END *** GLOBAL ROBOT *** HELPER METHODS ***********************************************/
         
})($, _);