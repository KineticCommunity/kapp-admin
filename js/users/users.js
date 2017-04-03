/* JS Specific to the User Management Console */
(function($, _) {
    /*----------------------------------------------------------------------------------------------
     * DOM MANIPULATION AND EVENT REGISTRATION 
     *   This section is executed on page load to register events and otherwise manipulate the DOM.
     *--------------------------------------------------------------------------------------------*/
    $(function() {
        
        $("table[data-user-list]").each(function(i,table){
            userManagement.usersTable = $(table);
            userManagement.loadUsers();
        });
        
        // User actions
        $("button.save-user").on("click", userManagement.saveUser);
        $("button.delete-user").on("click", userManagement.deleteUser);
        $("a.add-attribute-row").on("click", userManagement.addAttributeRow)
        $("div[data-allows-multiple=true]").on("blur", "input[type=text]", userManagement.removeEmptyAttributeRows);
        $("div.user-teams").on("click", ".add-team button", userManagement.addTeamMembership);
        $("div.user-teams").on("click", ".team-label .badge", userManagement.removeTeamMembership);
        
        
        
        $("input#users-import").on("change", userManagement.importUsersFileSelected);
        
        $("table[data-user-groups-table]").each(function(i,table){
            userManagement.initializeGroupsTable($(table));
        });
        
        $("table[data-user-attributes-table], table[data-user-profile-attributes-table]").each(function(i,table){
            userManagement.initializeAttributesTable($(table));
        });
        
        $("button.save-user-btn").on("click", userManagement.saveUser);
        $("a.download-import-template").on("click", userManagement.downloadUserImportTemplate);
    });

    /*----------------------------------------------------------------------------------------------
     * COMMON INIALIZATION 
     *   This code is executed when the Javascript file is loaded
     *--------------------------------------------------------------------------------------------*/
    // Ensure the BUNDLE global object exists
    bundle = typeof bundle !== "undefined" ? bundle : {};
    // Create namespace for Admin Kapp
    bundle.adminUsers = bundle.adminUsers || {};
    
    // Private namesapce for user management
    var userManagement = new Object();
    _.templateSettings = { interpolate: /\{\{(.+?)\}\}/g };

    /*----------------------------------------------------------------------------------------------
     * COMMON FUNCTIONS
     *--------------------------------------------------------------------------------------------*/
    
    userManagement.loadUsers = function(){
        var options = {
            columns: [
                {
                    title: "Username",
                    data: "username",
                    class: "all",
                    renderType: "gravatar"
                },
                {
                    title: "Display Name",
                    data: "displayName",
                    renderType: "text"
                },
                {
                    title: "Email",
                    data: "email",
                    renderType: "text"
                },
                {
                    title: "Enabled",
                    data: "enabled",
                    renderType: "boolLabel"
                },
                {
                    title: "",
                    defaultContent: "",
                    class: "all",
                    renderType: "actions",
                    orderable: false,
                    searchable: false
                },
                {
                    title: "Teams",
                    defaultContent: "",
                    class: "none",
                    renderType: "teams"
                },
                {
                    title: "Roles",
                    defaultContent: "",
                    class: "none",
                    renderType: "roles"
                }
            ],
            ajax: {
                url: bundle.apiLocation() + "/users?include=memberships",
                dataSrc: "users"
            },
            language: {
                search: "Filter"
            },
            responsive: true,
            pageLength: 25,
            stateSave: true
        };
        bundle.admin.addDataTableRenderers(options.columns, {
            actions: function (d, type, row){
                return "<div class=\"btn-group\">" +
                    "<a href=\"" + bundle.kappLocation() + "/" + bundle.adminUsers.consoleSlug + 
                        "?page=users/user&username=" + encodeURIComponent(row.username) + 
                        "\" class=\"btn btn-xs btn-default edit\" title=\"Edit\"><span class=\"fa fa-pencil fa-fw\"></span></a>" +
                    "<a href=\"" + bundle.kappLocation() + "/" + bundle.adminUsers.consoleSlug + 
                        "?page=users/user&clone=" + encodeURIComponent(row.username) + 
                        "\" class=\"btn btn-xs btn-warning clone\" title=\"Clone\"><span class=\"fa fa-clone fa-fw\"></span></a>" +
                "</div>";
            }, 
            gravatar: function(d, type, row){
                return "<img src=\"https://www.gravatar.com/avatar/" + 
                    md5(row.email) + "?s=64&d=mm\" " + 
                    "class=\"gravatarimg\" width=\"32px\" height=\"32px\"> " + d;
            },
            teams: function(d, type, row){
                if (type === "export" || type == "sort" || type == "type"){
                    return d;
                }
                return $.map(row.memberships, function(membership){
                    if (!membership.team.name.match("^Role::")){
                        return membership.team.name;
                    }
                    else {
                        return null;
                    }
                }).sort().map(function(team){
                    return "<label class=\"label label-default\">" + team + "</label>"
                }).join(" ") || "<em>None</em>";
            },
            roles: function(d, type, row){
                if (type === "export" || type == "sort" || type == "type"){
                    return d;
                }
                return $.map(row.memberships, function(membership){
                    if (membership.team.name.match("^Role::")){
                        return membership.team.name.substring(6);
                    }
                    else {
                        return null;
                    }
                }).sort().map(function(team){
                    return "<label class=\"label label-default\">" + team + "</label>"
                }).join(" ") || "<em>None</em>";
            },
            boolLabel: function(d, type, row){
                if (d === true){
                    return "<label class=\"label label-success\"><span class=\"fa fa-check\"></span> <span>Yes</span></label>";
                }
                else {
                    return "<label class=\"label label-danger\"><span class=\"fa fa-times\"></span> <span>No</span></label>";
                }
            }
        });
        // Build DataTable
        userManagement.usersTable.DataTable(options);
    };
    
    /**
     * Click event handler for adding an input box for an attribute that allows multiple values
     */
    userManagement.addAttributeRow = function(e){
        var container = $(this).closest("div[data-allows-multiple]");
        container.find("input").first()
             .clone()
             .val("")
             .css("display", "none")
             .appendTo(container)
             .slideDown(120)
             .focus();
    };
    
    /**
     * Removes extra empty inputs on attributes that allow multiple
     */
    userManagement.removeEmptyAttributeRows = function(e){
        if ($(this).val().trim().length <= 0 && $(this).siblings("input[type=text]").length > 0){
            $(this).slideUp(120, function(){$(this).remove()});
        }
    };
    
    userManagement.addTeamMembership = function(e){
        var teamsContainer = $(this).closest("div.user-teams");
        var availableTeams = $(this).closest(".add-team").find("select#available-teams");
        if (availableTeams.val().trim().length > 0){
            var selectedOption = availableTeams.find("option:selected");
            var team = {
                teamName: availableTeams.val(),
                teamSlug: selectedOption.data("team-slug"),
                teamIcon: selectedOption.data("team-icon"),
                teamDisplayName: selectedOption.text()
            };
            if (teamsContainer.find(".team-label[data-team-slug='" + team.teamSlug + "']").length <= 0){
                var newTeamTemplate = _.template($(this).closest("div.user-teams").siblings(".team-label-template").html());
                var newTeam = $(newTeamTemplate(team)).css("display", "none");
                var order = teamsContainer.find(".team-label").filter(function(){
                    return $(this).data("team-name") < team.teamName;
                }).length;
                if (order){
                    $(teamsContainer.find(".team-label").get(order - 1)).after(newTeam);
                }
                else {
                    teamsContainer.find("h4").after(newTeam);
                }
                newTeam.slideDown(120, function(){
                    userManagement.buildAvailableTeamsSelect(teamsContainer);
                });
            }
            else {
                userManagement.buildAvailableTeamsSelect(teamsContainer);
            }
        }
        else {
            $(this).closest(".add-team").find("select#available-teams").focus();
        }
    };

    userManagement.removeTeamMembership = function(e){
        var teamsContainer = $(this).closest("div.user-teams");
        $(this).closest(".team-label").slideUp(120, function(){
            $(this).remove();
            userManagement.buildAvailableTeamsSelect(teamsContainer);
        });
    };
    
    userManagement.buildAvailableTeamsSelect = function(teamsContainer){
        var availableTeams = teamsContainer.find("select#available-teams").empty();
        teamsContainer.find("select#source-teams option").each(function(i, o){
            if (teamsContainer.find(".team-label[data-team-slug='" + $(o).data("team-slug") + "']").length <= 0){
                availableTeams.append($(o).clone());
            }
        });
    };
    
    userManagement.saveUser = function(e){
        var self = $(this);
        var details = $("div.user-details");
        var create = details.find("input#user-username").length > 0;
        var user = {
            username: create ? details.find("input#user-username").val() : bundle.admin.getUrlParameters("username"),
            displayName: details.find("input#user-display-name").val().trim(),
            email: details.find("input#user-email").val().trim(),
            preferredLocale: details.find("select#user-preferred-locale").val().trim(),
            enabled: details.find("input#user-enabled").prop("checked"),
            spaceAdmin: details.find("input#user-space-admin").prop("checked"),
            attributes: new Array(),
            profileAttributes: new Array(),
            memberships: new Array()
        };
        
        // Collect all attributes from the dom into an array
        $("div.user-attributes div[data-user-attribute]").each(function(){
            var attribute = {
                name: $(this).data("user-attribute"),
                values: new Array()
            };
            $(this).find("input[type=text]").each(function(){
                if ($(this).val().trim().length > 0){
                    attribute.values.push($(this).val().trim());
                }
            });
            if (attribute.values.length > 0){
                user.attributes.push(attribute);
            }
        });
        
        // Collect all profile attributes from the dom into an array
        $("div.user-profile-attributes div[data-profile-attribute]").each(function(){
            var attribute = {
                name: $(this).data("profile-attribute"),
                values: new Array()
            };
            $(this).find("input[type=text]").each(function(){
                if ($(this).val().trim().length > 0){
                    attribute.values.push($(this).val().trim());
                }
            });
            $(this).find("input[type=radio]:checked").each(function(){
                if ($(this).val().trim().length > 0){
                    attribute.values.push($(this).val().trim());
                }
            });
            if (attribute.values.length > 0){
                user.profileAttributes.push(attribute);
            }
        });
        
        // Collect all team memberships from the dom into an array
        $("div.user-teams div.team-label[data-team-slug]").each(function(){
            user.memberships.push({
                team: { 
                    name: $(this).data("team-name")
                }
            });
        });
        
        // Collect all role memberships from the dom into an array
        $("div.user-roles input[type='checkbox']:checked").each(function(){
            user.memberships.push({
                team: { 
                    name: $(this).val()
                }
            });
        });
        
        $.ajax({
            method: create ? "post" : "put",
            url: encodeURI(bundle.apiLocation() + "/users/" + (create ? '' : user.username)),
            data: JSON.stringify(user),
            dataType: "json",
            contentType: "application/json",
            success: function(data){
                window.location.href = bundle.kappLocation() + "/" + bundle.adminUsers.consoleSlug;
            },
            error: function(jqXHR, textStatus, errorThrown){
                try { 
                    errorThrown = JSON.parse(jqXHR.responseText).error; 
                } catch(e){}
                self.notifie({
                    anchor: "div",
                    message: "An error occurred while saving the user: " + errorThrown,
                    exitEvents: "click"
                });
            }
        });
    }
    
    userManagement.deleteUser = function(e){
        var self = $(this);
        var username = bundle.admin.getUrlParameters("username");
        (new KD.Modal({
            header: "Confirm Delete",
            body: "Are you sure you want to delete the user <strong>" + username + "</strong>?",
            footer: function(element, actions) {
                element.addClass("text-right").append(
                    $("<button>", {class: "btn btn-success"}).text("Yes").on("click", actions.accept),
                    $("<button>", {class: "btn btn-link"}).text("Cancel").on("click", actions.dismiss)
                );
            },
            size: "md",
            backdrop: true,
            backdropclose: true,
            keyboardclose: true,
            renderCallback: false,
            accept: function(e){
                // If delete is confirmed, delete the team
                $.ajax({
                    method: "DELETE",
                    url: bundle.apiLocation() + "/users/" + username,
                    contentType: "application/json",
                    success: function(data, textStatus, jqXHR){
                        // On success, redirect to kapp home
                        window.location.href = bundle.kappLocation() + "/" + bundle.adminUsers.consoleSlug;
                    },
                    error: function(jqXHR, textStatus, errorThrown){
                        try { 
                            errorThrown = JSON.parse(jqXHR.responseText).error; 
                        } catch(e){}
                        self.notifie({
                            anchor: "div",
                            message: "An error occurred while deleting the user: " + errorThrown,
                            exitEvents: "click"
                        });
                    }
                });
            }
        })).show();
        // Blur delete button
        self.blur();
    };

//    userManagement.wrapDeferreds = function(deferreds){
//        return $.map(deferreds, function(d) {
//            var wrapedDeferred = $.Deferred();
//            d.always(function() { wrapedDeferred.resolve(); });
//            return wrapedDeferred.promise();
//        });
//    }
//    
//    userManagement.importUsersOpen = function(){
//        // Check if File API is available
//        if (window.File && window.FileReader && window.FileList) {
//            $("input#users-import").trigger("click");
//        }
//        else {
//            $("div.users-table-buttons").notifie({
//                anchor: "h3",
//                message: "Your browser does not support the import feature. Please use a newer browser."
//            });
//        }
//    };
//    
//    userManagement.importUsersFileSelected = function(e){
//        var importInput = $(this);
//        // Get files from file input
//        var fileList = importInput.prop("files");
//        // If file uploaded
//        if (fileList.length > 0){
//            // Get first file
//            var file = fileList.item(0);
//            // If not CSV file
//            if (file.name && file.name.slice(-4).toLowerCase() !== ".csv"){
//                importInput.closest("div.users-table-buttons").notifie({
//                    anchor: "h3",
//                    message: "Invalid file (" + file.name + "). Only files of type CSV are allowed.",
//                    exitEvents: "mouseup"
//                });
//            }
//            else {
//                // Initialize FileReader
//                var reader = new FileReader();
//                // Setup onload function which will process the import
//                reader.onload = function(e){
//                    userManagement.importUsersProcessData($.csv.toObjects(e.target.result), importInput);
//                }
//                // Read file
//                reader.readAsText(file);
//            }
//        }
//        // Reset file input value to empty string to allow on change  to fire on the same file if needed
//        importInput.val("");
//    };
//    
//    userManagement.importUsersProcessData = function(data, input){
//        var records = new Array();
//        _.each(data, function(d){
//            var newUser = {
//                username: d["Username"] || "",
//                displayName: d["Display Name"] || "",
//                email: d["Email"] || "",
//                enabled: d["Enabled"] && d["Enabled"].toLowerCase() === "true",
//                attributes: []
//            };
//            if (d["Groups"]){
//                newUser.attributes = [
//                   {
//                       name: "Group",
//                       values: JSON.parse(d["Groups"])
//                   }
//               ];
//            }
//            records.push(newUser);
//        });
//        
//        if (records.length > 0){
//            // Clear and destroy table and show notification that import is happening
//            userManagement.userDataTable.destroy();
//            userManagement.userTable.empty()
//            .append($("<tr>")
//                    .append($("<td>").addClass("alert alert-info")
//                            .append($("<span>").addClass("fa fa-cog fa-spin"))
//                            .append(" Importing users")));
//        }
//        else {
//            input.closest("div.users-table-buttons").notifie({
//                anchor: "h3",
//                message: "The file you selected doe not contain any data."
//            });
//        }
//        
//        // Create counters to keep track of when ajax calls complete
//        var statusCounters = {
//            totalRows: records.length,
//            processedRows: 0,
//            createdRows: 0,
//            createErrors: 0,
//            failedRows: new Array()
//        };
//        
//        // Iterate through each row in the imported csv. Delay with set timeout to allow for loader to be rendered.
//        window.setTimeout(function(){
//            _.each(records, function(row){
//                $.ajax({
//                    method: "POST",
//                    url: bundle.apiLocation() + "/users",
//                    dataType: "json",
//                    data: JSON.stringify(row),
//                    contentType: "application/json",
//                    success: function(data, textStatus, jqXHR){
//                        statusCounters.createdRows++;
//                        statusCounters.processedRows++;
//                        userManagement.importUsersStatusReport(statusCounters, input);
//                    },
//                    error: function(jqXHR, textStatus, errorThrown){
//                        try { 
//                            errorThrown = JSON.parse(jqXHR.responseText).error; 
//                        } catch(e){}
//                        statusCounters.failedRows.push($.extend(row, {"ERROR": errorThrown}));
//                        statusCounters.createErrors++;
//                        statusCounters.processedRows++;
//                        userManagement.importUsersStatusReport(statusCounters, input);
//                    }
//                });
//            });
//        }, 0);
//    };
//    
//    userManagement.importUsersStatusReport = function(statusCounters, input){
//        if (statusCounters.processedRows == statusCounters.totalRows){
//            var msg = $("<div>");
//            msg.append($("<div>").append($("<span>", {class: "fa fa-fw"}))
//                    .append(statusCounters.processedRows + " rows were processed."));
//            if (statusCounters.createdRows > 0){
//                msg.append($("<div>").append($("<span>", {class: "fa fa-check fa-fw"}))
//                        .append(statusCounters.createdRows + " users were created successfully."));
//            }
//            if (statusCounters.createErrors > 0){
//                msg.append($("<div>").append($("<span>", {class: "fa fa-times fa-fw"}))
//                        .append(statusCounters.createErrors + " users failed to be created."));
//            }
//            if (statusCounters.failedRows.length > 0){
//                var failuresContainer = $("<div>", {class: "import-has-errors hide"}).appendTo(msg);
//                var table = $("<table>").addClass("table table-hover table-bordered dt-responsive nowrap").appendTo(failuresContainer);
//                var failures = $.extend({}, userManagement.buildUserListTableOptions({users: statusCounters.failedRows}), {
//                    buttons: [
//                        {
//                            extend: "csv",
//                            text: "Export CSV of Failed Rows",
//                            className: "export-failures",
//                            filename: userManagement.userTable.data("space-name") + " Users - Failed Import Rows",
//                            exportOptions: {
//                                modifier: {
//                                    search: "none"
//                                },
//                                columns: ":not(.ignore-export)",
//                                orthogonal: "export"
//                            }
//                        }
//                    ],
//                    dom: 'B'
//                });
//                failures.columns.push({
//                    title: "ERROR",
//                    data: "ERROR"
//                });
//                var failureTable = table.DataTable(failures);
//                msg.append($("<div>").addClass("pull-right").append(failureTable.buttons().container()));
//            }
//            input.closest("div.users-table-buttons").notifie({
//                severity: statusCounters.failedRows.length > 0 ? "danger" : "info",
//                anchor: "h3",
//                message: msg
//            });
//            userManagement.loadUserList(userManagement.userTable);
//        }
//    };
//    
//    userManagement.buildUserListTableOptions = function(data, spaceName){
//        return {
//            responsive: true,
//            stateSave: true,
//            data: data.users,
//            columns: [
//                {
//                    title: "Username",
//                    data: "username",
//                    render: $.fn.dataTable.render.text()
//                },
//                {
//                    title: "Display Name",
//                    data: "displayName",
//                    class: "all",
//                    render: $.fn.dataTable.render.text()
//                },
//                {
//                    title: "Enabled",
//                    data: "enabled",
//                    render: $.fn.dataTable.render.boolean()
//                },
//                {
//                    title: "Groups",
//                    data: "attributes",
//                    render: $.fn.dataTable.render.attributes("Group")
//                },
//                {
//                    title: "Email",
//                    data: "email",
//                    render: $.fn.dataTable.render.text()
//                },
//                {
//                    defaultContent: $("div.users-table-actions-template").html(),
//                    class: "actions-sm all ignore-export",
//                    orderable: false,
//                    searchable: false
//                }
//            ],
//            buttons: [
//                {
//                    extend: "csv",
//                    text: "Export CSV",
//                    filename: (spaceName || "kinops") + " Users",
//                    exportOptions: {
//                        modifier: {
//                            search: "none"
//                        },
//                        columns: ":not(.ignore-export)",
//                        orthogonal: "export"
//                    }
//                },
//                {
//                    text: "Import CSV",
//                    action: userManagement.importUsersOpen
//                }
//            ],
//            pageLength: 25
//        };
//    };
//    
//    userManagement.downloadUserImportTemplate = function(e){
//        var table = $("<table>").DataTable({
//            columns: [
//                {title: "Display Name", data: "displayName"},
//                {title: "Username", data: "username"},
//                {title: "Enabled", data: "enabled"},
//                {title: "Groups", data: "groups"},
//                {title: "Email", data: "email"}
//            ],
//            data: [{
//                displayName: "DELETE THIS ROW BEFORE IMPORTING",
//                username: "",
//                enabled: "TRUE or FALSE",
//                groups: "[\"Group 1\",\"Group 2\",\"Group N\"]",
//                email: ""
//            }],
//            buttons: [{
//                extend: "csv",
//                filename: userManagement.userTable.data("space-name") + " Users - Import Template",
//                exportOptions: {
//                    modifier: { search: "none" },
//                    columns: ":not(.ignore-export)",
//                    orthogonal: "export"
//                }
//            }],
//            dom: 'B'
//        });
//        table.buttons().trigger("click");
//    };
//    
    
    
    /*----------------------------------------------------------------------------------------------
     * DEFINE RENDERERS FOR DATATABLES 
     *--------------------------------------------------------------------------------------------*/
    
    /**
     * Renderer for formatting text.
     */
    $.fn.dataTable.render.text = function(){
        return function ( d, type, row ){
            return d || "";
        };
    };

    /**
     * Renderer for formatting text.
     */
    $.fn.dataTable.render.boolean = function(){
        return function ( d, type, row ){
            if (type !== "export"){
                return d === true ? "Yes" : "No";
            }
            return d;
        };
    };
    
    /**
     * Renderer for displaying attribute values.
     */
    $.fn.dataTable.render.attributes = function(attribute){
        return function ( d, type, row ){
            var groups = _.findWhere(d, {name: attribute}); 
            if (type === "export"){
                return groups ? JSON.stringify(groups.values) : "";
            }
            if (groups){
                var result = "<ul>";
                _.each(groups.values, function(v, i){
                    result += "<li>" + v + "</li>"
                });
                result += "</ul>";
                return result;
            }
            else if (d){
                return "";
            }
            return d;
        };
    };
         
})($, _);