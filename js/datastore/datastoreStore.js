/* JS Specific to the Datastore Console (Store Page) */
(function($, _) {
    /*----------------------------------------------------------------------------------------------
     * DOM MANIPULATION AND EVENT REGISTRATION 
     *   This section is executed on page load to register events and otherwise manipulate the DOM.
     *--------------------------------------------------------------------------------------------*/
    $(function() {
        
        $("table[data-datastore-records-table]").each(function(i,table){
            ds.store.loadTable($(table));
        });

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
    var adminDatastore = bundle.adminDatastore;
    
    // Private namespace for datastore
    var ds = {
        config: {},
        store: {},
        record: {}
    };
    _.templateSettings = { interpolate: /\{\{(.+?)\}\}/g };

    /*----------------------------------------------------------------------------------------------
     * STORE PAGE FUNCTIONS
     *--------------------------------------------------------------------------------------------*/
    
    /**
     * Initializes the table of records for the current datastore
     * 
     * @param table jQuery table that will show the records
     */
    ds.store.loadTable = function(table){
        ds.store.table = table;
        
        // Load table and data
        ds.store.loadRecords(false, false);
        
        // Add import event handler
        $("input#datastore-records-import").on("change", ds.store.processImportFile);
        
        // Add button event handlers
        table.on("click", "button.delete", ds.store.deleteRecord);
    };
    
    /**
     * Loads the records for the current datastore and displays them in a DataTable
     * 
     * @param previousChunk boolean specifying if previous 2000 records should be fetched in a large volume datastore.
     * @param nextChunk boolean specifying if next 2000 records should be fetched in a large volume datastore.
     * @param query JS Object specifying fields and values to search on when retrieving data for a large volume datastore.
     */
    ds.store.loadRecords = function(previousChunk, nextChunk, query){
        // Get columns for the table
        $.ajax({
            method: "GET",
            url: bundle.kappLocation() + "?partial=" + "datastore/columns.json&store=" + bundle.adminDatastore.storeSlug,
            dataType: "json",
            contentType: "application/json",
            beforeSend: function(){
                // Destroy table if it already exists
                if ($.fn.DataTable.isDataTable(ds.store.table)){
                    ds.store.table.DataTable().destroy();
                    ds.store.table.empty();
                    ds.store.table.append("<tr><td class=\"alert alert-info\"><span class=\"fa fa-spinner fa-spin\"></span>Loading</td>");
                }
            },
            success: function(columnData, textStatus, jqXHR){
                // Create datatable options
                var options = $.extend(columnData, {
                    ajax: function(data, callback){
                        // Build url for fetching the correct data
                        var url = bundle.kappLocation() + "?partial=" + "datastore/data.json&store=" + bundle.adminDatastore.storeSlug;
                        // Add any query parts
                        $.each(ds.store.table.data("query") || {}, function(k, v){
                            url += "&" + encodeURIComponent("values[" + k + "]") + "=" + encodeURIComponent(v);
                        });
                        // Add pageToken if large volume datastore
                        if (ds.store.table.data("pageToken")){
                            url += "&pageToken=" + ds.store.table.data("pageToken");
                        }
                        // Get the appropriate data
                        $.ajax({
                            method: "GET",
                            url: url,
                            dataType: "json",
                            contentType: "application/json",
                            success: function(data){
                                callback(data);
                            },
                            error: function(jqXHR, textStatus, errorThrown){
                                try { errorThrown += ": " + JSON.parse(jqXHR.responseText).error; } catch(e){}
                                ds.store.table.DataTable().destroy();
                                ds.store.table.empty().notifie({
                                    message: "Failed to load records for the " + bundle.adminDatastore.storeName + " datastore.<br>" + errorThrown
                                });
                            }
                        });
                    },
                    responsive: true,
                    pageLength: 25,
                    stateSave: true,
                    // Load the pageToken and previous pageTokens from the state of the table
                    stateLoadParams: function (settings, data) {
                        ds.store.table.data("query", query || data.query);
                        // If query is passed in, reset to first chunk
                        if (query){
                            ds.store.table.data("pageToken", "");
                            ds.store.table.data("previousPageTokens", []);
                            data.start = 0;
                        }
                        // If we want the previous chunk, pop the last pageToken and set as the current pageToken
                        else if (previousChunk){
                            var previous = data.previousPageTokens || [];
                            ds.store.table.data("pageToken", previous.pop());
                            ds.store.table.data("previousPageTokens", previous);
                            data.start = 0;
                        }
                        // If we want the next chunk, push the current pageToken to the previous pageTokens stack
                        // and set the nextPageToken as the current pageToken
                        else if (nextChunk){
                            var previous = data.previousPageTokens || [];
                            previous.push(data.pageToken || "");
                            ds.store.table.data("pageToken", ds.store.table.data("nextPageToken"));
                            ds.store.table.data("previousPageTokens", previous);
                            data.start = 0;
                        }
                        else {
                            ds.store.table.data("pageToken", data.pageToken || "");
                            ds.store.table.data("previousPageTokens", data.previousPageTokens || []);
                        }
                    },
                    // Save the pageToken and previous pageTokens along with the state of the table
                    stateSaveParams: function (settings, data) {
                        data.pageToken = ds.store.table.data("pageToken") || "";
                        data.previousPageTokens = ds.store.table.data("previousPageTokens") || [];
                        data.query = ds.store.table.data("query");
                    },
                    initComplete: function(settings, json){
                        // If data returns a nextPageToken or has a pageToken or query, then it's a large volume datastore
                        ds.store.table.data("nextPageToken", json._nextPageToken || null);
                        if (json._nextPageToken || ds.store.table.data("pageToken") 
                                || (ds.store.table.data("query") && !$.isEmptyObject(ds.store.table.data("query")))){
                            ds.store.initLargeVolume(json);
                        }
                        // Append the import/export buttons to the buttons section on the page
                        ds.store.table.DataTable().buttons().nodes().each(function(){
                            $("div.datastore-records-table-buttons").prepend($(this).attr("href", "#")).prepend("\n");
                        });
                    },
                    language: {
                        search: "Filter:",
                        emptyTable: "No records found."
                    },
                    buttons: [
                        {
                            extend: "csv",
                            text: "Export CSV",
                            filename: bundle.adminDatastore.storeName + " Datastore",
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
                            action: ds.store.importRecords
                        }
                    ]
                });
                bundle.admin.addDataTableRenderers(options.columns, {
                    actionButtons: function ( d, type, row ){
                        return "<div class=\"btn-group datastore-btns\">" +
                    		"<a href=\"" + bundle.kappLocation() + "/" + bundle.adminDatastore.consoleSlug + 
                    		    "?page=datastore/record&store=" + bundle.adminDatastore.storeSlug + "&id=" + row.ID + 
                    		    "\" class=\"btn btn-xs btn-default edit\" title=\"Edit\"><span class=\"fa fa-pencil fa-fw\"></span></a>" +
                    		"<a href=\"" + bundle.kappLocation() + "/" + bundle.adminDatastore.consoleSlug + 
                                "?page=datastore/record&store=" + bundle.adminDatastore.storeSlug + "&clone=" + row.ID + 
                                "\" class=\"btn btn-xs btn-success clone\" title=\"Clone\"><span class=\"fa fa-clone fa-fw\"></span></a>" +
                    		"<button class=\"btn btn-xs btn-danger delete\" title=\"Delete\"><span class=\"fa fa-times fa-fw\"></span></button>" +
                		"</div>";
                    }
                });
                // Build DataTable
                ds.store.table.DataTable(options);
            },
            error: function(jqXHR, textStatus, errorThrown){
                try { errorThrown += ": " + JSON.parse(jqXHR.responseText).error; } catch(e){}
                ds.store.table.empty().notifie({
                    message: "Failed to load records for the " + bundle.adminDatastore.storeName + " datastore.<br>" + errorThrown
                });
            }
        });
    };
    
    /**
     * Shows and initializes the UI components used for a large volume datastore.
     * 
     * @param json Current chunk of data returned from the API
     */
    ds.store.initLargeVolume = function(json){
        // Update chunk pagination info
        var previousPageTokens = ds.store.table.data("previousPageTokens") || [];
        $("div#datastore-records-chunk-pagination strong.chunk-info").text(
                "Records " + (Math.min(1, json.data.length) + (previousPageTokens.length * 2000)) 
                + " to " +  (json.data.length + (previousPageTokens.length * 2000))
                + " are shown in the table above."
        );
        $("div#datastore-records-chunk-pagination button.previous-chunk").prop("disabled", previousPageTokens.length <= 0);
        $("div#datastore-records-chunk-pagination button.next-chunk").prop("disabled", json._nextPageToken == null || json._nextPageToken.length <= 0);
        
        // Update large volume search criteria display to show current query (needs to be rebuilt after a refresh)
        var query = ds.store.table.data("query") || {};
        $("div#datastore-records-criteria-display span.badge:not(.reset)").each(function(){
            if (query[$(this).data("field")] == null){
                $(this).remove();
            }
            $(this).find("strong.value").text(query[$(this).data("field")]);
        });
        $.each(query, function(k, v){
            if ($("div#datastore-records-criteria-display span.badge[data-field='" + k + "']").length <= 0){
                $("div#datastore-records-criteria-display span.badge.reset").before(
                    $("<span>", {class: "badge", "data-field": k}).append(
                        $("<span>", {class: "field"}).text(k),
                        $("<strong>", {class: "value"}).text(v),
                        $("<span>", {class: "fa fa-times"})
                    )
                );
            }
        });
        
        // Show large volume controls if hidden and initialize events
        if ($("div.large-volume-datastore").hasClass("hide")){
            $("div.large-volume-datastore").removeClass("hide");
            
            $("div#datastore-records-chunk-pagination button.previous-chunk").on("click", function(){
                $("div#datastore-records-chunk-pagination strong.chunk-info").empty();
                ds.store.loadRecords(true, false);
            });
            $("div#datastore-records-chunk-pagination button.next-chunk").on("click", function(){
                $("div#datastore-records-chunk-pagination strong.chunk-info").empty();
                ds.store.loadRecords(false, true);
            });
            
            $("div#datastore-records-criteria-value button.search").on("click", function(){
                // If field or value is empty, focus the select/input
                var field = $("div#datastore-records-criteria-field select");
                if (field.val().length <= 0){
                    field.focus();
                    return;
                }
                var value = $("div#datastore-records-criteria-value input");
                if (value.val().length <= 0){
                    value.focus();
                    return;
                }
                
                $("div#datastore-records-criteria-display span.badge[data-field='" + field.val() + "']").remove();
                $("div#datastore-records-criteria-display").prepend(
                    $("<span>", {class: "badge", "data-field": field.val()}).append(
                        $("<span>", {class: "field"}).text(field.val()),
                        $("<strong>", {class: "value"}).text(value.val()),
                        $("<span>", {class: "fa fa-times"})
                    )
                );
                field.val("");
                value.val("");
                
                ds.store.table.trigger("query");
            });
            
            $("div#datastore-records-criteria-display").on("click", "span.badge span.fa-times", function(){
                $(this).closest("span.badge").remove();
                ds.store.table.trigger("query");
            });
            
            $("div#datastore-records-criteria-display").on("click", "span.badge.reset", function(){
                $(this).siblings().remove();
                ds.store.table.trigger("query");
            });
            
            ds.store.table.on("query", function(){
                var q = {};
                $("div#datastore-records-criteria-display span.badge:not(.reset)").each(function(){
                    q[$(this).data("field")] = $(this).find("strong.value").text();
                });
                $("div#datastore-records-chunk-pagination strong.chunk-info").empty();
                ds.store.loadRecords(false, false, q);
            });
        }
    };

    /**
     * If browser supports File API, begin import process. Otherwise throw error.
     */
    ds.store.importRecords = function(){
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
    };
    
    /**
     * Event handler for importing a file. Verifies that file is a CSV and parses it.
     */
    ds.store.processImportFile = function(e){
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
                    ds.store.processImportRecords($.csv.toObjects(e.target.result), importInput);
                }
                // Read file
                reader.readAsText(file);
            }
        }
        // Reset file input value to empty string to allow on change  to fire on the same file if needed
        importInput.val("");
    };
    
    /**
     * Save each row of data as a submission for the given Datastore.
     * 
     * @param importData Array of Objects to be saved.
     * @param importInput jQuery instance of file input element.
     */
    ds.store.processImportRecords = function(importData, importInput){
        /** Retrieve all fields in the datastore **/
        $.ajax({
            method: 'GET',
            url: bundle.apiLocation() + "/kapps/" + bundle.kappSlug() + "/forms/" + bundle.adminDatastore.storeSlug + "?include=fields",
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
                    // Close any top level alerts
                    importInput.closest("div.datastore-records-table-buttons").notifie({
                        anchor: "h3",
                        exit: true
                    });
                    // Clear and destroy table and show notification that import is happening
                    ds.store.table.DataTable().destroy();
                    ds.store.table.empty()
                        .append($("<tr>")
                            .append($("<td>").addClass("alert alert-info")
                                .append($("<span>").addClass("fa fa-cog fa-spin"))
                                .append(" Importing " + importData.length + " records")));
                    
                    // Create counters to keep track of when ajax calls complete
                    var statusCounters = {
                        totalRows: importData.length,
                        startedRows: 0,
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
                            // Delay if more than 100 pending ajax calls
                            (function processDelay(row, importInput, statusCounters) {
                                if(statusCounters.startedRows - statusCounters.processedRows > 100){
                                    setTimeout(function(){ processDelay(row, importInput, statusCounters); }, 1000);
                                }
                                else {
                                    ds.store.processSingleImportRecord(row, importInput, statusCounters);
                                }
                            })(row, importInput, statusCounters);
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
    };
    
    /**
     * Save a single row of data.
     * Update the row if Datastore Record ID is passed in, otherwise create a new row.
     *  
     * @param row Data to save.
     * @param importInput jQuery instance of file input element.
     * @param statusCounters Object for keeping track of multiple ajax calls.
     */
    ds.store.processSingleImportRecord = function(row, importInput, statusCounters){
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
                url: bundle.apiLocation() + "/kapps/" + bundle.kappSlug() + "/forms/" + bundle.adminDatastore.storeSlug + "/submissions",
                dataType: "json",
                data: JSON.stringify({values: row}),
                contentType: "application/json",
                beforeSend: function(){
                    statusCounters.startedRows++;
                },
                success: function(data, textStatus, jqXHR){
                    statusCounters.createdRows++;
                    statusCounters.processedRows++;
                    ds.store.calculateImportResults(statusCounters, importInput);
                },
                error: function(jqXHR, textStatus, errorThrown){
                    statusCounters.failedRows.push($.extend(row, {"Datastore Record ID": "", "ERROR": errorThrown}));
                    statusCounters.createErrors++;
                    statusCounters.processedRows++;
                    ds.store.calculateImportResults(statusCounters, importInput);
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
                beforeSend: function(){
                    statusCounters.startedRows++;
                },
                success: function(data, textStatus, jqXHR){
                    statusCounters.updatedRows++;
                    statusCounters.processedRows++;
                    ds.store.calculateImportResults(statusCounters, importInput);
                },
                error: function(jqXHR, textStatus, errorThrown){
                    statusCounters.failedRows.push($.extend(row, {"Datastore Record ID": datastoreRecordID, "ERROR": errorThrown}));
                    statusCounters.updateErrors++;
                    statusCounters.processedRows++;
                    ds.store.calculateImportResults(statusCounters, importInput);
                }
            });
        }
    }
    
    /**
     * Check if all ajax calls for import have completed.
     * If they have, show results.  
     * 
     * @param statusCounters Object for keeping track of multiple ajax calls.
     * @param importInput jQuery instance of file input element.
     */
    ds.store.calculateImportResults = function(statusCounters, importInput){
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
                            className: "export-failures",
                            filename: bundle.adminDatastore.storeName + " Datastore - Failed Import Rows",
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
            ds.store.loadRecords(false, false, {});
        }
    }
    
    /**
     * Event handler for Delete button click. Verifies that user wants to delete a record and deletes it. 
     */
    ds.store.deleteRecord = function(e){
        // On click of delete button, confirm that the user is sure they want to delete
        var self = $(this);
        // Get selected row data
        var row = ds.store.table.DataTable().row($(this).closest("tr"));
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
    };
    
    
})($, _);