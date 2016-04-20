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
                                window.location.replace(bundle.kappLocation() + "/" + self.data("console-slug") + "?kapp=" + bundle.kappSlug() 
                                        + "&page=" + self.data("console-slug") + "/config&store=" + data.form.slug);
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
            $("input#datastore_slug").val($(this).val().trim().toLowerCase().replace(/[^a-z\s-]/g, "").replace(/\s+/g, "-"));
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
                    window.location.replace(bundle.kappLocation() + "/" + self.data("console-slug") + "?kapp=" + bundle.kappSlug() 
                            + "&page=" + self.data("console-slug") + "/config&store=" + data.form.slug);
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
            $.ajax({
                mathod: "GET",
                url: bundle.kappLocation() + "?partial=" + "datastore/records.json&store=" + $("table#datastore-records-table").data("datastore-slug"),
                dataType: "json",
                contentType: "application/json",
                success: function(data, textStatus, jqXHR){
                    records = $.extend(data, {
                        responsive: true,
                        pageLength: 25,
                        buttons: [
                            /*{
                                text: "Import CSV",
                                className: "btn-sm",
                                action: importDatastoreRecords
                            },*/
                            {
                                extend: "csv",
                                text: "Export CSV",
                                className: "btn-sm",
                                exportOptions: {
                                    modifier: {
                                        search: "none"
                                    }
                                }
                            }
                        ]
                    });
                    $.each(records.columns, function( i, v){
                        v.visible = (v.visible === "true") ? true : false;
                        v.searchable = (v.searchable === "true") ? true : false;
                        v.orderable = (v.orderable === "true") ? true : false;
                    });
                    var datastoreRecordsTable = $("table#datastore-records-table").DataTable(records);
                    $("div.datastore-records-table-buttons").prepend(datastoreRecordsTable.buttons().nodes());
                    var consoleSlug = $("table#datastore-records-table").data("console-slug");
                    var kappSlug = $("table#datastore-records-table").data("kapp-slug");
                    var datastoreSlug = $("table#datastore-records-table").data("datastore-slug");
                    window.dst = datastoreRecordsTable;
                    
                    $("table#datastore-records-table").on("click", "button.edit", function(e){
                        var data = datastoreRecordsTable.row($(this).closest("tr")).data();
                        location.replace(bundle.kappLocation() + "/" + consoleSlug + "?kapp=" + kappSlug + "&page=datastore/record&store=" + datastoreSlug + "&id=" + data.ID);
                    }).on("click", "button.delete", function(e){
                        var self = $(this);
                        var row = datastoreRecordsTable.row($(this).closest("tr"));
                        var data = row.data();
                        console.log(data);
                        var confirmDelete = new KD.Modal({
                            header: "<h3>Confirm Delete</h3>",
                            body: "Are you sure you want to delete this record?",
                            footer: function(element, actions) {
                                element.addClass("text-right").append(
                                    $("<button>").addClass("btn btn-success").text("Yes").on("click", actions.accept),
                                    $("<button>").addClass("btn btn-link").text("Cancel").on("click", actions.dismiss)
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
                    })
                }
            });
            
            $("input#datastore-records-import").on("change", function(e){
                var datastoreSlug = $("table#datastore-records-table").data("datastore-slug");
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
                        importInput.closest("div.datastore-records-table-buttons").notifie({
                            anchor: "h3",
                            message: "This feature is not yet implemented.",
                            exitEvents: "mouseup"
                        });
                        /*
                        var reader = new FileReader();
                        reader.onload = function(e){
                            var csvObjectsArray = $.csv.toObjects(e.target.result);
                            // Retrieve all fields in the datastore
                            $.ajax({
                                method: 'GET',
                                url: bundle.apiLocation() + "/kapps/" + bundle.kappSlug() + "/forms/" + datastoreSlug + "?include=fields",
                                dataType: "json",
                                contentType: "application/json",
                                success: function(response, textStatus, jqXHR){},
                                error: function(jqXHR, textStatus, errorThrown){
                                    importInput.closest("div.datastore-records-table-buttons").notifie({
                                        anchor: "h3",
                                        message: "An error occurred while importing records: " + errorThrown,
                                        exitEvents: "mouseup"
                                    });
                                }
                            });
                        }
                        reader.readAsText(file);
                        */
                    }
                }
            });
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
     
})($, _);