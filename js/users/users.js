/* JS Specific to the User Management Console */
(function($, _) {
    /*----------------------------------------------------------------------------------------------
     * DOM MANIPULATION AND EVENT REGISTRATION 
     *   This section is executed on page load to register events and otherwise manipulate the DOM.
     *--------------------------------------------------------------------------------------------*/
    $(function() {
        
        $("table[data-user-list]").each(function(i,table){
            userManagement.loadUserList($(table));
        });
        
        $("input#users-import").on("change", userManagement.importUsersFileSelected);
        
        $("table[data-user-groups-table]").each(function(i,table){
            userManagement.initializeGroupsTable($(table));
        });
        
        $("table[data-user-attributes-table], table[data-user-profile-attributes-table]").each(function(i,table){
            userManagement.initializeAttributesTable($(table));
        });
        
        $("button.save-user-btn").on("click", userManagement.saveUser);
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
    
    // Private namesapce for user management
    var userManagement = new Object();
    _.templateSettings = { interpolate: /\{\{(.+?)\}\}/g };

    /*----------------------------------------------------------------------------------------------
     * COMMON FUNCTIONS
     *--------------------------------------------------------------------------------------------*/
    
    userManagement.initializeGroupsTable = function(table){
        userManagement.populateGroupOptions(table);
        table.on("click", "tbody a.delete-group-btn", userManagement.deleteGroup);
        table.on("click", "tfoot button.add-group-btn", userManagement.addGroup);
    }

    userManagement.initializeAttributesTable = function(table){
        userManagement.populateAttributeOptions(table);
        table.on("click", "tbody a.delete-attribute-btn", userManagement.deleteAttribute);
        table.on("click", "tfoot button.add-attribute-btn", userManagement.addAttribute);
    }
    
    userManagement.populateGroupOptions = function(table){
        var options = table.find("select.add-group-name-field-options");
        var select = table.find("select.add-group-name-field").empty().append($("<option>"));
        var groups = $.map(table.find("tbody tr td.group-name"), function(td){
            return $(td).text();
        });
        options.find("option").sort(function (a, b){
            return $(a).text() == $(b).text() ? 0 : $(a).text() < $(b).text() ? -1 : 1;
        }).each(function(i, option){
            if (!_.contains(groups, $(option).val())){
                select.append($(option).clone());
            }
        });
    };
    
    userManagement.deleteGroup = function(e){
        var table = $(this).closest("table");
        $(this).closest("tr").remove();
        userManagement.populateGroupOptions(table);
    }
    
    userManagement.addGroup = function(e){
        var table = $(this).closest("table");
        var group = $(this).closest("tr").find("select.add-group-name-field").val();
        if (group){
            var template = _.template(table.find("tfoot.template").html());
            table.find("tbody").append(template({group: group}));
            userManagement.populateGroupOptions(table);
        }
        else {
            $(this).notifie({
                anchor: "table",
                message: "Please select the group you would like to add.",
                exitEvents: "click"
            });
        }
    }

    userManagement.populateAttributeOptions = function(table){
        var options = table.find("select.add-attribute-name-field-options");
        var select = table.find("select.add-attribute-name-field").empty().append($("<option>"));
        var groups = $.map(table.find("tbody tr td.attribute-name"), function(td){
            return $(td).text();
        });
        options.find("option").sort(function (a, b){
            return $(a).text() == $(b).text() ? 0 : $(a).text() < $(b).text() ? -1 : 1;
        }).each(function(i, option){
            if ($(option).data("allows-multiple") || !_.contains(groups, $(option).val())){
                select.append($(option).clone());
            }
        });
    };
    
    userManagement.deleteAttribute = function(e){
        var table = $(this).closest("table");
        $(this).closest("tr").remove();
        userManagement.populateAttributeOptions(table);
    }
    
    userManagement.addAttribute = function(e){
        var table = $(this).closest("table");
        var attributeName = $(this).closest("tr").find("select.add-attribute-name-field").val();
        var attributeValue = $(this).closest("tr").find("input.add-attribute-value-field").val();
        if (attributeName && attributeValue){
            var template = _.template(table.find("tfoot.template").html());
            table.find("tbody").append(template({attributeName: attributeName, attributeValue: attributeValue}));
            $(this).closest("tr").find("input.add-attribute-value-field").val("");
            userManagement.populateAttributeOptions(table);
        }
        else {
            $(this).notifie({
                anchor: "table",
                message: "Please select an attribute name and enter a value.",
                exitEvents: "click"
            });
        }
    }
    
    userManagement.saveUser = function(e){
        var createUser = $("input[name=username]").length ? true : false;
        var user = {
            username: $("input[name=username]").val() || bundle.admin.getUrlParameters("username"),
            displayName: $("input[name=displayName]").val(),
            email: $("input[name=email]").val(),
            preferredLocale: $("select[name=preferredLocale]").val(),
            enabled: $("input[name=enabled]").prop("checked"),
            //spaceAdmin: $("input[name=spaceAdmin]").prop("checked"),
            attributes: new Array(),
            profileAttributes: new Array()
        };
        
        var groups = new Array();
        var attributes = new Object();
        var profileAttributes = new Object();
        
        $("table[data-user-groups-table] tbody tr td.group-name").each(function(i, td){
            var group = $(td).text();
            if (!attributes["Group"]){
                attributes["Group"] = new Array();
            }
            attributes["Group"].push(group);
            groups.push(group);
        }); 
        
        $("table[data-user-attributes-table] tbody tr").each(function(i, tr){
            var name = $(tr).find("td.attribute-name").text();
            var value = $(tr).find("td.attribute-value input").val();
            if (!attributes[name]){
                attributes[name] = new Array();
            }
            attributes[name].push(value);
        }); 

        $("table[data-user-profile-attributes-table] tbody tr").each(function(i, tr){
            var name = $(tr).find("td.attribute-name").text();
            var value = $(tr).find("td.attribute-value input").val();
            if (!profileAttributes[name]){
                profileAttributes[name] = new Array();
            }
            profileAttributes[name].push(value);
        }); 
        
        user.attributes = $.map(attributes, function(value, key){
            return {name: key, values: value};
        });
        user.profileAttributes = $.map(profileAttributes, function(value, key){
            return {name: key, values: value};
        });
        
        if (createUser && !user.username){
            $("input[name=username]").notifie({
                message: "Username is required.",
                exitEvents: "keyup"
            });
        }
        else if (createUser){
            userManagement.createUser(user, groups);
        }
        else {
            userManagement.updateUser(user, groups);
        }
    };
    
    userManagement.updateUser = function(user, groups){
        $.ajax({
            method: "put",
            url: encodeURI(bundle.apiLocation() + "/users/" + user.username),
            dataType: "json",
            contentType: "application/json",
            data: JSON.stringify(user),
            beforeSend: function(){
                $("button.save-user-btn").notifie({
                    anchor: "div.row",
                    severity: "info",
                    message: $("<div>").append(
                        $("<span>", {class: "fa fa-spinner fa-spin"}),
                        $("<span>").append("Saving User")
                    ),
                    margin: {'margin':'0'},
                    exitEvents: "click"
                });
            },
            success: function(data){
                userManagement.syncGroupMembership(user.username, groups);
            },
            error: function(jqXHR, textStatus, errorThrown){
                try { 
                    errorThrown = JSON.parse(jqXHR.responseText).error; 
                } catch(e){}
                $("button.save-user-btn").notifie({
                    anchor: "div.row",
                    message: "An error occurred while updating the user: " + errorThrown,
                    margin: {'margin':'0'},
                    exitEvents: "click"
                });
            }
        });
    }

    userManagement.createUser = function(user, groups){
        $.ajax({
            method: "post",
            url: encodeURI(bundle.apiLocation() + "/users"),
            contentType: "application/json",
            dataType: "json",
            data: JSON.stringify(user),
            beforeSend: function(){
                $("button.save-user-btn").notifie({
                    anchor: "div.row",
                    severity: "info",
                    message: $("<div>").append(
                        $("<span>", {class: "fa fa-spinner fa-spin"}),
                        $("<span>").append("Saving User")
                    ),
                    margin: {'margin':'0'},
                    exitEvents: "click"
                });
            },
            success: function(data){
                userManagement.syncGroupMembership(user.username, groups);
            },
            error: function(jqXHR, textStatus, errorThrown){
                try { 
                    errorThrown = JSON.parse(jqXHR.responseText).error; 
                } catch(e){}
                $("button.save-user-btn").notifie({
                    anchor: "div.row",
                    message: "An error occurred while creating the user: " + errorThrown,
                    margin: {'margin':'0'},
                    exitEvents: "click"
                });
            }
        });
    }
    
    userManagement.syncGroupMembership = function(username, groups){
        $.ajax({
            url: encodeURI(bundle.apiLocation() + "/kapps/" + bundle.kappSlug() 
                    + "/forms/group-membership/submissions?" 
                    + "include=values&limit=1000&q=values[Username]=\"" + username + "\""),
            dataType: "json",
            contentType: "application/json",
            success: function(data){
                var membershipMap = new Object();
                _.each(data.submissions, function(submission){
                    membershipMap[submission.values["Group Name"]] = submission.id;
                });
                var memberships = _.keys(membershipMap);
                var groupsToAdd = _.difference(groups, memberships);
                var groupsToDelete = _.difference(memberships, groups);
                
                var deferreds = new Array();
                var status = {success: 0, error: 0};
                _.each(groupsToAdd, function(group){
                    deferreds.push(userManagement.addGroupMembership(username, group, status));
                });
                _.each(groupsToDelete, function(group){
                    deferreds.push(userManagement.removeGroupMembership(membershipMap[group], status));
                });
                
                $.when.apply($, userManagement.wrapDeferreds(deferreds)).done(function(){
                    if (status.error > 0){
                        $("button.save-user-btn").notifie({
                            anchor: "div.row",
                            message: "Failed to update " + status.error + " group memberships for this user",
                            margin: {'margin':'0'},
                            expire: 5000,
                            onConfirm: function(){
                                window.location.href = window.location.pathname;
                            }
                        });
                    }
                    else {
                        window.location.href = window.location.pathname;
                    }
                });
            },
            error: function(jqXHR, textStatus, errorThrown){
                try { 
                    errorThrown = JSON.parse(jqXHR.responseText).error; 
                } catch(e){}
                $("button.save-user-btn").notifie({
                    anchor: "div.row",
                    message: "Failed to update group memberships for this user: " + errorThrown,
                    margin: {'margin':'0'},
                    expire: 5000,
                    onConfirm: function(){
                        window.location.href = window.location.pathname;
                    }
                });
            }
        });
    }
    
    userManagement.addGroupMembership = function(username, group, status){
        return $.ajax({
            method: "post",
            url: encodeURI(bundle.apiLocation() + "/kapps/" + bundle.kappSlug() 
                    + "/forms/group-membership/submissions"),
            dataType: "json",
            contentType: "application/json",
            data: JSON.stringify({  
                values: {
                    "Username": username,
                    "Group Name": group
                }
            }),
            success: function(data){
                status.success++;
            },
            error: function(){
                status.error++;
            }
        });
    }
    
    userManagement.removeGroupMembership = function(id, status){
        return $.ajax({
            method: "delete",
            url: encodeURI(bundle.apiLocation() + "/submissions/" + id),
            dataType: "json",
            contentType: "application/json",
            success: function(data){
                status.success++;
            },
            error: function(){
                status.error++;
            }
        });
    }
    
    userManagement.wrapDeferreds = function(deferreds){
        return $.map(deferreds, function(d) {
            var wrapedDeferred = $.Deferred();
            d.always(function() { wrapedDeferred.resolve(); });
            return wrapedDeferred.promise();
        });
    }
    
    userManagement.importUsersOpen = function(){
        // Check if File API is available
        if (window.File && window.FileReader && window.FileList) {
            $("input#users-import").trigger("click");
        }
        else {
            $("div.users-table-buttons").notifie({
                anchor: "h3",
                message: "Your browser does not support the import feature. Please use a newer browser."
            });
        }
    };
    
    userManagement.importUsersFileSelected = function(e){
        var importInput = $(this);
        // Get files from file input
        var fileList = importInput.prop("files");
        // If file uploaded
        if (fileList.length > 0){
            // Get first file
            var file = fileList.item(0);
            // If not CSV file
            if (file.name && file.name.slice(-4).toLowerCase() !== ".csv"){
                importInput.closest("div.users-table-buttons").notifie({
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
                    userManagement.importUsersProcessData($.csv.toObjects(e.target.result), importInput);
                }
                // Read file
                reader.readAsText(file);
            }
        }
        // Reset file input value to empty string to allow on change  to fire on the same file if needed
        importInput.val("");
    };
    
    userManagement.importUsersProcessData = function(data, input){
        var records = new Array();
        _.each(data, function(d){
            var newUser = {
                username: d["Username"] || "",
                displayName: d["Display Name"] || "",
                email: d["Email"] || "",
                enabled: d["Enabled"] && d["Enabled"].toLowerCase() === "true",
                attributes: []
            };
            if (d["Groups"]){
                newUser.attributes = [
                   {
                       name: "Group",
                       values: JSON.parse(d["Groups"])
                   }
               ];
            }
            records.push(newUser);
        });
        
        // Clear and destroy table and show notification that import is happening
        userManagement.userDataTable.destroy();
        userManagement.userTable.empty()
            .append($("<tr>")
                .append($("<td>").addClass("alert alert-info")
                    .append($("<span>").addClass("fa fa-cog fa-spin"))
                    .append(" Importing users")));
        
        // Create counters to keep track of when ajax calls complete
        var statusCounters = {
            totalRows: records.length,
            processedRows: 0,
            createdRows: 0,
            createErrors: 0,
            failedRows: new Array()
        };
        
        // Iterate through each row in the imported csv. Delay with set timeout to allow for loader to be rendered.
        window.setTimeout(function(){
            _.each(records, function(row){
                $.ajax({
                    method: "POST",
                    url: bundle.apiLocation() + "/users",
                    dataType: "json",
                    data: JSON.stringify(row),
                    contentType: "application/json",
                    success: function(data, textStatus, jqXHR){
                        statusCounters.createdRows++;
                        statusCounters.processedRows++;
                        userManagement.importUsersStatusReport(statusCounters, input);
                    },
                    error: function(jqXHR, textStatus, errorThrown){
                        try { 
                            errorThrown = JSON.parse(jqXHR.responseText).error; 
                        } catch(e){}
                        statusCounters.failedRows.push($.extend(row, {"ERROR": errorThrown}));
                        statusCounters.createErrors++;
                        statusCounters.processedRows++;
                        userManagement.importUsersStatusReport(statusCounters, input);
                    }
                });
            });
        }, 0);
    };
    
    userManagement.importUsersStatusReport = function(statusCounters, input){
        if (statusCounters.processedRows == statusCounters.totalRows){
            var msg = $("<div>");
            msg.append($("<div>").append($("<span>", {class: "fa fa-fw"}))
                    .append(statusCounters.processedRows + " rows were processed."));
            if (statusCounters.createdRows > 0){
                msg.append($("<div>").append($("<span>", {class: "fa fa-check fa-fw"}))
                        .append(statusCounters.createdRows + " users were created successfully."));
            }
            if (statusCounters.createErrors > 0){
                msg.append($("<div>").append($("<span>", {class: "fa fa-times fa-fw"}))
                        .append(statusCounters.createErrors + " users failed to be created."));
            }
            if (statusCounters.failedRows.length > 0){
                var failuresContainer = $("<div>", {class: "import-has-errors hide"}).appendTo(msg);
                var table = $("<table>").addClass("table table-hover table-striped table-bordered dt-responsive nowrap").appendTo(failuresContainer);
                var failures = $.extend({}, userManagement.buildUserListTableOptions({users: statusCounters.failedRows}), {
                    buttons: [
                        {
                            extend: "csv",
                            text: "Export CSV of Failed Rows",
                            className: "btn-sm export-failures",
                            filename: userManagement.userTable.data("space-name") + " Users - Failed Import Rows",
                            exportOptions: {
                                modifier: {
                                    search: "none"
                                },
                                columns: ":not(.ignore-export)",
                                orthogonal: "export"
                            }
                        }
                    ],
                    dom: 'B'
                });
                failures.columns.push({
                    title: "ERROR",
                    data: "ERROR"
                });
                var failureTable = table.DataTable(failures);
                msg.append($("<div>").addClass("pull-right").append(failureTable.buttons().container()));
            }
            input.closest("div.users-table-buttons").notifie({
                severity: statusCounters.failedRows.length > 0 ? "danger" : "info",
                anchor: "h3",
                message: msg
            });
            userManagement.loadUserList(userManagement.userTable);
        }
    };
    
    userManagement.loadUserList = function(table){
        userManagement.userTable = table;
        $.ajax({
            method: "GET",
            url: encodeURI(bundle.apiLocation() + "/users?include=attributes"),
            dataType: "json",
            contentType: "application/json",
            success: function(data){
                var options = userManagement.buildUserListTableOptions(data, table.data("space-name"));
                userManagement.userDataTable = table.DataTable(options);
                // Append the import/export buttons to the buttons section on the page
                userManagement.userDataTable.buttons().nodes().each(function(){
                    $("div.users-table-buttons").prepend($(this).attr("href", "#")).prepend("\n");
                });
                // Add event handler for edit button
                userManagement.userTable.off().on("click", "button.edit-user-btn", function(e){
                    // On click of edit button, send user to page for editing current user
                    var data = userManagement.userDataTable.row($(this).closest("tr")).data();
                    location.href = bundle.kappLocation() + "/" + userManagement.userTable.data("console-slug") + "?page=users/user&username=" + data.username;
                });
            },
            error: function(jqXHR, textStatus, errorThrown){
                try { 
                    errorThrown = JSON.parse(jqXHR.responseText).error; 
                } catch(e){}
                table.empty().notifie({
                    message: "Failed to load users.<br>" + errorThrown
                });
            }
        });
    };
    
    userManagement.buildUserListTableOptions = function(data, spaceName){
        return {
            responsive: true,
            stateSave: true,
            data: data.users,
            columns: [
                {
                    title: "Display Name",
                    data: "displayName",
                    class: "all",
                    render: $.fn.dataTable.render.text()
                },
                {
                    title: "Username",
                    data: "username",
                    render: $.fn.dataTable.render.text()
                },
                {
                    title: "Enabled",
                    data: "enabled",
                    render: $.fn.dataTable.render.boolean()
                },
                {
                    title: "Groups",
                    data: "attributes",
                    render: $.fn.dataTable.render.attributes("Group")
                },
                {
                    title: "Email",
                    data: "email",
                    render: $.fn.dataTable.render.text()
                },
                {
                    defaultContent: "<div class=\"btn-group pull-right\" role=\"group\"><button class=\"edit-user-btn btn btn-xs btn-default\" type=\"button\"><span class=\"fa fa-pencil\"></span></button></div>",
                    class: "actions-xs all ignore-export",
                    orderable: false,
                    searchable: false
                }
            ],
            buttons: [
                {
                    extend: "csv",
                    text: "Export CSV",
                    className: "btn-sm ",
                    filename: (spaceName || "kinops") + " Users",
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
                    action: userManagement.importUsersOpen
                }
            ],
            pageLength: 25
        };
    };
    
    
    
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