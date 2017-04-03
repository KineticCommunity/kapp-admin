(function($, _) {
    /*----------------------------------------------------------------------------------------------
     * DOM MANIPULATION AND EVENT REGISTRATION
     *   This section is executed on page load to register events and otherwise manipulate the DOM.
     *--------------------------------------------------------------------------------------------*/  
    $(function() {    

        // Add Add Click Event to Save System Button
        $("button.update-object-btn").on("click", sharedManagement.updateObject);

        // Build Up approver attribute DOM
        if($('.attribute input[name="Approver"]').length > 0){
            sharedManagement.buildApprovalDOM();
        }

        // Bind Team Assignee events
        if($('.attribute input[name="Task Assignee Team"]').length > 0){
            sharedManagement.buildTaskAssigneeDOM();
        }

        // Display alert if stored attribute Value doesn't exist in list
        // This is specifically for notification templates that no longer exist but
        // are set as attributes.
        $('.attribute select, .attributes select').each(function(){
            if ($(this).attr('value') !== undefined && $(this).attr('value').trim() !== $(this).val()){
                $(this).parent().find('label').append('<span style="color:red;"> (*** Alert! Stored Attribute Value Doesn\'t Exist ***)</span>');
            }
        })
        
        bundle.adminManagement.init();
        // Enable update and reset buttons
        $(document).on("click", "button[data-save-button]", bundle.adminManagement.save);
        $(document).on("click", "button[data-reset-button]", bundle.adminManagement.reset);

     });

    /*----------------------------------------------------------------------------------------------
     * COMMON INIALIZATION 
     *   This code is executed when the Javascript file is loaded
     *--------------------------------------------------------------------------------------------*/
    // Ensure the BUNDLE global object exists
    bundle = typeof bundle !== "undefined" ? bundle : {};
    // Create namespace for Admin Kapp Management Console
    bundle.adminManagement = bundle.adminManagement || {};
    
    // Private namesapce for system management
    var sharedManagement = new Object();
    _.templateSettings = { interpolate: /\{\{(.+?)\}\}/g };

    /*----------------------------------------------------------------------------------------------
     * COMMON FUNCTIONS
     *--------------------------------------------------------------------------------------------*/
    
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
    
    bundle.adminManagement.save = function(){
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
    
    bundle.adminManagement.reset = function(){
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
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    sharedManagement.updateObject = function(){

        var path = $("button.update-object-btn").data('ajaxpath')
        var type = $("button.update-object-btn").data('objecttype')

        // Build object to hold Space Object
        var object = {
            attributes: new Array()
        };
        // Build object to hold Attribute Values
        var attributes = new Object();

        // Populate Attributes Object based on attribute inputs
        // Since ALL of the attributes are listed in a hidden element
        // they will all be added to the attributes array. They will
        // Be overridden by the attributes that are visible in to the 
        // user though.
        $('div.attribute input.attributeValue, div.attribute select.attributeValue').each(function(){
            var name = this.name;
            var value = this.value;
            attributes[name] = [value];
        });

        // Handle attributes that have multiple values
        $('div.attribute select.attributeValues').each(function(){
            var name = $( this ).attr('name');
            var value = $( this ).val() || []
            attributes[name] = value;
        });

        // Overwrite Attributes that have multiple values with what was selected
        $('div.multiAttributes').each(function(){
            var value = []
            var name = $( this ).attr('name');

            // Handle Checkboxs
            if ( $(this).find('input:checkbox').length > 0 ) {
                $(this).find('input:checkbox:checked').each(function(){
                    value.push($(this).val());
                });
            }
            // Handle Multi-Select Inputs
            else if ( $(this).find('select').length > 0 ) {
                value = $(this).find('select').val() || [];
            }
            attributes[name] = value;
        });

        // Add the Attributes to the Space Object if they have a value
        object.attributes = $.map(attributes, function(value, key){
            if (!_.isEmpty(value[0])) return {name: key, values: value};  
        });

        // Handle Additional Form Properties like Description and Categories
        if(type === "Form"){
            //var categories = new Object();
            var description = $('.formDescription textarea').val();
            object['description'] = description;
        }

        // Update the Space
        $.ajax({
            method: "put",
            url: encodeURI(bundle.apiLocation() + path),
            dataType: "json",
            contentType: "application/json",
            data: JSON.stringify(object),
            beforeSend: function(){
                $("button.update-object-btn").notifie({
                    anchor: "div.row",
                    severity: "info",
                    message: $("<div>").append(
                        $("<span>", {class: "fa fa-spinner fa-spin"}),
                        $("<span>").append("Updating " + type)
                    ),
                    margin: {'margin':'0'},
                    exitEvents: "click"
                });
            },
            success: function(data){
                window.location.reload();
            },
            error: function(jqXHR, textStatus, errorThrown){
                try { 
                    errorThrown = JSON.parse(jqXHR.responseText).error; 
                } catch(e){}
                $("button.update-object-btn").notifie({
                    anchor: "div.row",
                    message: "An error occurred while updating the " + type + ": " + errorThrown,
                    margin: {'margin':'0'},
                    exitEvents: "click"
                });
            }
        });
    }

    sharedManagement.buildTaskAssigneeDOM = function(){
        // Build Variables to hold Team and Assignee Elements
        var taskTeamElement = $('.attribute select[name="Task Assignee Team"]');
        var taskAssigneeElement = $('#teamAssigneeId select');

        // If a team is selected on page load, get its members and  
        // build / show the Assignee Selector
        if (!_.isEmpty(taskTeamElement.val())) {
            getMembershipOptions(taskTeamElement.val());
        }

        // Bind Listner to the Team selector and bind change function to get members
        taskTeamElement.change(function(){
            var teamName = $(this).val();
            taskAssigneeElement.parent().hide();
            getMembershipOptions(teamName);
        });

        // Function that gets team members and returns <options> Elements.
        function getMembershipOptions(teamName){
            // Remove Current Options
            taskAssigneeElement.find('option').remove();
            // GET team members
            $.ajax({
                method: "get",
                url: encodeURI(bundle.apiLocation() + "/teams"),
                dataType: "json",
                contentType: "application/json",
                success: function(data){
                    teamObj = _.find(data.teams, function(team) {
                        return team.name === teamName; 
                    })

                    if(!_.isEmpty(teamObj)){
                        $.ajax({
                            method: "get",
                            url: encodeURI(bundle.apiLocation() + "/teams/" + teamObj.slug + "?include=memberships.user.details"),
                            dataType: "json",
                            contentType: "application/json",
                            success: function(data){
                                var memberships = data.team.memberships;
                                if(!_.isEmpty(memberships)){
                                    taskAssigneeElement.append($('<option/>'));
                                    $.each(memberships,function(){
                                        taskAssigneeElement.append($('<option/>').val(this.user.username).text(this.user.displayName))
                                    });
                                    taskAssigneeElement.parent().show();
                                }
                            },
                            error: function(jqXHR, textStatus, errorThrown){
                                console.log("error getting team memberships");
                            }
                        });
                    }
                },
                error: function(jqXHR, textStatus, errorThrown){
                    console.log("error getting team while finding memberships");
                }
            });
        }
    }

    // Function for Building up the Approval Options for the Approver Attribute
    sharedManagement.buildApprovalDOM = function(){
        // Manipulate Approver Section
        var approverElement = $('.attribute input[name="Approver"]');

        var teamsList = $('#approverTeams select')[0].options;
        teamsList = $.map(teamsList, function(obj){return [obj.value]});

        var usersList = $('#approverIndividuals select')[0].options;
        usersList = $.map(usersList, function(obj){return [obj.value]});

        // Select None if attribute is empty
        if (approverElement.val().trim() === "" || approverElement.val().toLowerCase() === "none"){
            $('.attribute input[data-type="none"]').prop('checked', true);
        }
        // Select Manager if attribute is set to manager
        else if (approverElement.val().toLowerCase() === "manager"){
            $('.attribute input[data-type="manager"]').prop('checked', true);
        }
        // Select Team if attribute is a valid Team
        else if ($.inArray(approverElement.val(), teamsList) !== -1) {
            $('.attribute input[data-type="team"]').prop('checked', true);
            $('#approverTeams select').val(approverElement.val()).parent().show();
        } 
        // Select Team if attribute is a valid User
        else if ($.inArray(approverElement.val(), usersList) !== -1) {
            $('.attribute input[data-type="individual"]').prop('checked', true);
            $('#approverIndividuals select').val(approverElement.val()).parent().show();
        } 
        // If none match, assume None and wipe the Current Attribute Value because the data is bad
        else {
            $('.attribute input[data-type="none"]').prop('checked', true);
            approverElement.val(null);
        }

        // Build listner for Radio Button Changes on Approval Attributes
        $('.attribute .approvalRadios input[type="radio"]').change(function(){
            if ($(this).data('type') === "team"){
                $('#approverTeams select').val(null).focus().parent().show();
                $('#approverIndividuals select').val(null).parent().hide();
            }
            else if ($(this).data('type') === "individual"){
                $('#approverTeams select').val(null).parent().hide();
                $('#approverIndividuals select').val(null).focus().parent().show();
            }
            else if ($(this).data('type') === "manager"){
                $('#approverTeams select').val(null).parent().hide();
                $('#approverIndividuals select').val(null).parent().hide();
                $('#approverIndividuals select').val(null).parent().hide();
                approverElement.val("Manager");
            }
            else if ($(this).data('type') === "none"){
                $('#approverTeams select').val(null).parent().hide();
                $('#approverIndividuals select').val(null).parent().hide();
                approverElement.val(null);
            }
        });

        // Build listner for Individual and Team Dropdowns which sets the
        // Arrover Element that is saved to the system
        $('.attribute .approvalSelector').change(function(){
            approverElement.val($(this).val());
        });
    }

})(jQuery, _);
