(function($, _) {
    /*----------------------------------------------------------------------------------------------
     * DOM MANIPULATION AND EVENT REGISTRATION
     *   This section is executed on page load to register events and otherwise manipulate the DOM.
     *--------------------------------------------------------------------------------------------*/  
    $(function() {
        
        // Initialize UI elements such as iconPicker, (number) spinner, colorpicker, etc.
        bundle.adminManagement.init();
        
        // Enable update and reset buttons
        $(document).on("click", "button[data-save-button]", bundle.adminManagement.save);
        $(document).on("click", "button[data-reset-button]", bundle.adminManagement.reset);

        // Initialize DataTable for DOM built tables
        $("table[data-table-dom]").each(function(i,table){
            bundle.adminManagement.buildDomDataTable($(table));
        });
        // Initialize Forms List DataTable for DOM built table
        $("table[data-table-forms-list]").each(function(i,table){
            bundle.adminManagement.buildFormsDataTable($(table));
        });
        
        // Create click event to start a discussion for a form
        $("div.form-activity button#start-discussion").on("click", bundle.adminManagement.form.startDiscussion);
        
        // On load of page, if hash exists in url, open the appropriate tab
        if (location.hash){
            $(".nav-tabs[role=tablist]").each(function(){
                $(this).find("a[href='"+location.hash+"']").tab("show");
            });
        }

     });

    /*----------------------------------------------------------------------------------------------
     * COMMON INIALIZATION 
     *   This code is executed when the Javascript file is loaded
     *--------------------------------------------------------------------------------------------*/
    // Ensure the BUNDLE global object exists
    bundle = typeof bundle !== "undefined" ? bundle : {};
    // Create namespace for Admin Kapp Management Console
    bundle.adminManagement = bundle.adminManagement || {};
    bundle.adminManagement.form = bundle.adminManagement.form || {}; 

    // Private namesapce for system management
    var sharedManagement = {};
    _.templateSettings = { interpolate: /\{\{(.+?)\}\}/g };

    /*----------------------------------------------------------------------------------------------
     * COMMON FUNCTIONS
     *--------------------------------------------------------------------------------------------*/
    
    /**
     * Initialize UI elements within a container or the entire page if container is not passed in.
     */
    bundle.adminManagement.init = function(container){
        container = container || $(document);
        container.find(".colorpicker-component").colorpicker();
        container.find(".spinner").spinner().on("keypress", function(e){
            var keyCode = e.keyCode || e.which, 
                keysAllowed = [44, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 0, 8, 9, 13]; 
            if ($.inArray(keyCode, keysAllowed) === -1 && e.ctrlKey === false){ 
                e.preventDefault();
            }
        });
        container.find(".icp-auto").iconpicker({hideOnSelect: true});
    };
    
    /**
     * Event handler for saving management options from a single container. 
     * Fetches the source data with attributes to make sure we don't lose any attributes.
     */
    bundle.adminManagement.save = function(e){
        var self = $(this);
        var container = self.closest("div[data-save-container]");
        var url = bundle.apiLocation() + container.data("source");
        var sourceName = container.data("source-name");
        
        // Get current object with all attributes
        $.ajax({
            method: "get",
            dataType: "json",
            url: url + "?include=attributes",
            beforeSend: function(jqXHR, settings){
                self.prop("disabled", true)
                    .notifie({
                        anchor: "div",
                        severity: "info",
                        message: $("<div>").append(
                            $("<span>", {class: "fa fa-spinner fa-spin"}),
                            $("<span>").text("Saving")
                        )
                    });
            },
            success: function(data, textStatus, jqXHR){
                bundle.adminManagement.processSave(self, container, url, data[sourceName] || {});
            },
            error: function(jqXHR, textStatus, errorThrown){
                try { 
                    errorThrown = JSON.parse(jqXHR.responseText).error; 
                } catch(e){}
                self.notifie({
                    anchor: "div",
                    message: "An error occurred while performing the update: " + errorThrown,
                    exitEvents: "click"
                });
            }
        });
    };
    
    /**
     * Retrieves the data to save from within the dom elements and updates 
     * the existing attributes list to make sure no attributes are lost.
     */
    bundle.adminManagement.processSave = function(self, container, url, data){
        var saveData = {
            attributes: new Array()
        };
        
        // Convert list of existing attributes to a map
        var attributesMap = new Object();
        $.each(data.attributes, function(i, a){
            attributesMap[a.name] = a.values;
        });
        // Collect all attributes from the container and update map
        container.find("div[data-attribute]").each(function(){
            var name = $(this).data("attribute");
            var values = new Array();
            $(this).find(
                "input[type=text]:not(.ignore-value), " +
                "input[type=checkbox]:checked:not(.ignore-value), " +
                "input[type=radio]:checked:not(.ignore-value), " +
                "select:not([multiple]):not(.ignore-value), " +
                "textarea:not(.ignore-value)"
    		).each(function(){
                if ($(this).val() && $(this).val().trim().length > 0){
                    values.push($(this).val().trim());
                }
            });
            $(this).find("select[multiple]:not(.ignore-value)").each(function(){
                if ($(this).val() && $.isArray($(this).val())){
                    $.each($(this).val(), function(i, v){
                        if (v && v.trim().length > 0){
                            values.push(v.trim());
                        }
                    });
                }
            });
            if (values.length > 0){
                attributesMap[name] = values;
            }
            else {
                delete attributesMap[name];
            }
        });
        // Convert map of attributes back into an array for saving
        saveData.attributes = $.map(attributesMap, function(value, key){
            return {name: key, values: value};
        });
        
        // Collect all the properties from the container for saving
        container.find("div[data-property]").each(function(){
            var value = $(this).find(
                "input[type=text]:not(.ignore-value), " +
                "input[type=checkbox]:checked:not(.ignore-value), " +
                "input[type=radio]:checked:not(.ignore-value), " +
                "select:not(.ignore-value), " +
                "textarea:not(.ignore-value)"
            ).first();
            saveData[$(this).data("property")] = value.val();
        });
        
        // Collect categorizations (for forms) from the container for saving
        container.find("div[data-categorizations]").each(function(){
            var categories = new Array();
            $(this).find("input[type=checkbox]:checked:not(.ignore-value)").each(function(){
                if ($(this).val() && $(this).val().trim().length > 0){
                    categories.push($(this).val().trim());
                }

            });
            saveData.categorizations = $.map(categories, function(category){
                return {category: {slug: category}};
            });
        });
        
        // Update object
        $.ajax({
            method: "put",
            dataType: "json",
            url: url,
            data: JSON.stringify(saveData),
            success: function(data, textStatus, jqXHR){
                var configPartial = container.data("config-partial");
                if (configPartial){
                    container.load(bundle.kappLocation() + "?partial=management" + configPartial, function(){
                        bundle.adminManagement.init(container);
                    });
                }
                else {
                    self.notifie({anchor: "div", exit: true});
                }
            },
            error: function(jqXHR, textStatus, errorThrown){
                try { 
                    errorThrown = JSON.parse(jqXHR.responseText).error; 
                } catch(e){}
                self.notifie({
                    anchor: "div",
                    message: "An error occurred while performing the update: " + errorThrown,
                    exitEvents: "click"
                });
            },
            complete: function(jqXHR, settings){
                self.prop("disabled", false);
            }
        });
    };
    
    /** 
     * Reloads the partial for the current container
     */
    bundle.adminManagement.reset = function(e){
        var container = $(this).closest("div[data-save-container]");
        var configPartial = container.data("config-partial");
        if (configPartial){
            container.load(bundle.kappLocation() + "?partial=management" + configPartial, function(){
                bundle.adminManagement.init(container);
            });
        }
        else {
            window.location.reload();
        }
    };
    
    /**
     * Converts a table already built in the DOM to a datatable
     */
    bundle.adminManagement.buildDomDataTable = function(table){
        var pageLength = table.data("page-length") || 25;
        var options = {
            autoWidth: false,
            pageLength: pageLength,
            language: {
                search: "Filter"
            }
        };
        table.dataTable(options);
    };
    
    /**
     * Converts a forms list table build in the DOM to a datatable with toggleable attribute columns
     */
    bundle.adminManagement.buildFormsDataTable = function(table){
        var pageLength = table.data("page-length") || 25;
        var options = {
            autoWidth: false,
            dom: "<'row'<'col-sm-4'l><'col-sm-4 text-center'B><'col-sm-4'f>><'row'<'col-xs-12'<'overflow-auto't>>><'row'<'col-sm-5'i><'col-sm-7'p>>",
            pageLength: pageLength,
            language: {
                search: "Filter"
            },
            buttons: [
                {
                    extend: "colvis",
                    text: "Toggle Attribute Columns <span class='fa fa-caret-down'></span>",
                    collectionLayout: 'column-visibility-layout',
                    className: "column-visibility-button btn-subtle",
                    columns: ".visibility-toggle"
                }
            ]
        };
        table.dataTable(options);
    };
    
    /**
     * Event handler for starting a discussion on the form details page
     * Fetch the form since we'll need to store the discussion id as an attribute
     */
    bundle.adminManagement.form.startDiscussion = function(e){
        var self = $(this);
        // Get form
        $.ajax({
            method: "GET",
            url: encodeURI(bundle.apiLocation() + "/kapps/" + bundle.adminManagement.kappSlug + "/forms/" + bundle.adminManagement.formSlug + "?include=attributes,kapp"),
            dataType: "json",
            contentType: "application/json",
            beforeSend: function(){
                self.prop("disabled", true)
                    .notifie({
                        anchor: "div.row",
                        message: "<span class='fa fa-spinner fa-spin'></span> Starting Discussion",
                        margin: {'margin':'0'}
                    });
            },
            success: function(data, textStatus, jqXHR){
                bundle.adminManagement.form.createDiscussion(self, data.form);
            },
            error: function(jqXHR, textStatus, errorThrown){
                try { 
                    errorThrown += ": " +  JSON.parse(jqXHR.responseText).error; 
                } catch(e){}
                self.notifie({
                    anchor: "div.row",
                    message: "An error occurred when trying to start a new discussion while retrieving form information.<br>" + errorThrown,
                    margin: {'margin':'0'},
                    exitEvents: "click"
                });
            }
        });
    }
    
    /**
     * Call response api to start a discussion and save the discussion id as a form attribute
     */
    bundle.adminManagement.form.createDiscussion = function(self, form){
        $.ajax({
            method: "POST",
            url: encodeURI(bundle.adminManagement.responseUrl + "/api/v1/issues"),
            data: JSON.stringify({
                name: form.name,
                description: "",
                tag_list: "META:TYPE:Form," +
                          "META:ID:" + form.kapp.slug + '/' + form.slug
            }),
            dataType: "json",
            contentType: "application/json",
            xhrFields: {
                withCredentials: true
            },
            success: function(response, textStatus, jqXHR){
                // Build Discussion Id attribute
                var responseAttribute = {
                    name: "Discussion Id",
                    values: [response.guid]
                };
                form.attributes.push(responseAttribute);
                // Update form to add Response Id attribute
                $.ajax({
                    method: "PUT",
                    url: encodeURI(bundle.apiLocation() + "/kapps/" + bundle.adminManagement.kappSlug + "/forms/" + bundle.adminManagement.formSlug),
                    data: JSON.stringify(form),
                    dataType: "json",
                    contentType: "application/json",
                    success: function(data){
                        window.location.href = bundle.spaceLocation() + "?page=discussion&id=" + response.guid;
                    },
                    error: function(jqXHR, textStatus, errorThrown){
                        try { 
                            errorThrown = JSON.parse(jqXHR.responseText).error; 
                        } catch(e){}
                        self.notifie({
                            anchor: "div",
                            message: "An error occurred when saving the new discussion to the service: " + errorThrown,
                            exitEvents: "click"
                        });
                    }
                });
            },
            error: function(jqXHR, textStatus, errorThrown){
                try { 
                    errorThrown += ": " +  JSON.parse(jqXHR.responseText).error; 
                } catch(e){}
                self.notifie({
                    anchor: "div.row",
                    message: "An error occurred when trying to start a new discussion.<br>" + errorThrown,
                    margin: {'margin':'0'},
                    exitEvents: "click"
                });
            }
        });
    };

})(jQuery, _);
