(function($, _) {
    /*----------------------------------------------------------------------------------------------
     * DOM MANIPULATION AND EVENT REGISTRATION
     *   This section is executed on page load to register events and otherwise manipulate the DOM.
     *--------------------------------------------------------------------------------------------*/  
    $(function() {    
        /*
         * Initialize Colorpicker / Spinner
         */
        $('.colorpicker-component').colorpicker();
        $('.spinner').spinner()
        $('.icp-auto').iconpicker({hideOnSelect: true});

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
        

     });

    /*----------------------------------------------------------------------------------------------
     * COMMON INIALIZATION 
     *   This code is executed when the Javascript file is loaded
     *--------------------------------------------------------------------------------------------*/
    // Ensure the BUNDLE global object exists
    bundle = typeof bundle !== "undefined" ? bundle : {};
    // Create namespace for Admin Kapp
    bundle.adminProfiles = bundle.adminProfiles || {};
    // Create a scoped alias to simplify references to your namespace
    var adminProfiles = bundle.adminProfiles;
    
    // Private namesapce for system management
    var sharedManagement = new Object();
    _.templateSettings = { interpolate: /\{\{(.+?)\}\}/g };

    /*----------------------------------------------------------------------------------------------
     * COMMON FUNCTIONS
     *--------------------------------------------------------------------------------------------*/
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
            $('#approverTeams select').val(approverElement.val()).show();
        } 
        // Select Team if attribute is a valid User
        else if ($.inArray(approverElement.val(), usersList) !== -1) {
            $('.attribute input[data-type="individual"]').prop('checked', true);
            $('#approverIndividuals select').val(approverElement.val()).show();
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
                approverElement.val("manager");
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