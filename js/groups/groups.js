/* JS Specific to the Groups Console */
(function($, _) {
    /*----------------------------------------------------------------------------------------------
     * DOM MANIPULATION AND EVENT REGISTRATION 
     *   This section is executed on page load to register events and otherwise manipulate the DOM.
     *--------------------------------------------------------------------------------------------*/
    $(function() {
        
        /**
         * Show tooltip in flat groups table when hovering over parent cell to display full parent path
         */
        $("table.groups-table-flat [data-toggle='tooltip']").tooltip({
            delay: {show: 500, hide: 0 },
            placement: "left"
        });
        
        /**
         * Event handlers for hierarchy table
         */
        $("table.groups-table-hierarchy").on("click", "li.group-item.has-subgroups a", function(e){
            /** When link is clicked, don't expand/collapse level **/
            e.stopPropagation()
        }).on("click", "li.group-item.has-subgroups", function(e){
            /** When row with subgroups is clicked, expand/collapse it's children **/
            if ($(this).hasClass("open")){
                // If open, collapse children
                $(this).removeClass("open");
                $("table.groups-table-hierarchy").find("li[data-group-id='" + $(this).data("group-id") + "']").removeClass("open");
            }
            else {
                // If closed, expand children
                $(this).addClass("open");
                $("table.groups-table-hierarchy").find("li[data-group-id='" + $(this).data("group-id") + "']").addClass("open");
            }
        });
        
        /**
         * Event handler for toggling between flat view and hierarchy view of groups
         */
        $("span.table-view-buttons").on("click", "span", function(e){
            if (!$(this).hasClass("open")){
                $("span.table-view-buttons span, table.groups-table").removeClass("open");
                $(this).addClass("open");
                $("table.groups-table-" + $(this).data("table")).addClass("open");
            }
        });
        
        /**
         * Event handlers of collapse all and expand all buttons of hierarchy table
         */
        $("div.table-hierarchy-option").on("click", "button.collapse-all", function(e){
            $("table.groups-table-hierarchy li").removeClass("open");
        }).on("click", "button.expand-all", function(e){
            $("table.groups-table-hierarchy li").addClass("open");
        });
        
        
        /**
         * Code for page/tab which shows the group form for adding new groups or updating groups
         */
        if ($("div.group-form-container").length){
            // Get group container and groupId
            var groupContainer = $("div.group-form-container");
            var groupId = groupContainer.data("group-id");
            
            // If group id exists, we are editing a group
            if (groupId){
                // Load the group submission
                K.load({
                    path: bundle.spaceLocation() + "/submissions/" + groupId, 
                    container: groupContainer,
                    updated: function(data){
                        // On update refresh the page
                        location.reload();
                    },
                    loaded: function(form){
                        // On load, remove the cancel button which is only used on the add new group page
                        groupContainer.find("button.cancel-group").remove();
                        // Add section for displaying and editing the parent path
                        addParentPathSectionToForm(groupId, groupContainer, form);
                        // If group has subgroups, disable delete button and ake it show an error
                        if (groupContainer.data("has-subgroups")){
                            // Add event to show alert when delete is clicked that you can't delete a group with subgroups
                            groupContainer.on("click", "button.delete-group", function(e){
                                (new KD.Modal({
                                    header: "<h3>Not Allowed</h3>",
                                    body: "You can not delete a group which has subgroups. Please delete or move all subgroups first.",
                                    footer: function(element, actions) {
                                        element.addClass("text-right").append(
                                            $("<button>", {class: "btn btn-success"}).text("OK").on("click", actions.dismiss)
                                        );
                                    },
                                    size: "sm",
                                    backdrop: true,
                                    backdropclose: true,
                                    keyboardclose: true,
                                    renderCallback: false
                                })).show();
                                // Blur delete button
                                $(this).blur();
                            });
                        }
                        // If group doesn't have subgroups, enable delete group button with confirmation
                        else {
                            // Add event for handling delete of group
                            groupContainer.on("click", "button.delete-group", function(e){
                                (new KD.Modal({
                                    header: "<h3>Confirm Delete</h3>",
                                    body: "Are you sure you want to delete this group?",
                                    footer: function(element, actions) {
                                        element.addClass("text-right").append(
                                            $("<button>", {class: "btn btn-success"}).text("Yes").on("click", actions.accept),
                                            $("<button>", {class: "btn btn-link"}).text("Cancel").on("click", actions.dismiss)
                                        );
                                    },
                                    size: "sm",
                                    backdrop: true,
                                    backdropclose: true,
                                    keyboardclose: true,
                                    renderCallback: false,
                                    accept: function(e){
                                        // On accept of confirmation, delete the group
                                        deleteGroup(groupId, groupContainer);
                                    }
                                })).show();
                                // Blur delete button
                                $(this).blur();
                            });
                        }
                    }
                });
                
                /**
                 * On load of page, if hash exists in url, open the appropriate tab of the groups page
                 */
                if ($("div.groups-tab-content").length){
                    // Open tab based on hash if one exists
                    $("a[href='"+location.hash+"']").tab('show');
                }
            }
            // If group id doesn't exist, load new form to add a group
            else {
                K.load({
                    path: bundle.kappLocation() + "/group", 
                    container: groupContainer,
                    created: function(data){
                        // When group is created, redirect to edit group page
                        location.replace($("a.return-to-groups-console").attr("href") + "&page=groups/group&group=" + data.submission.id);
                    },
                    loaded: function(form){
                        // Remove delete button since group doesn't yet exist, and reset button
                        groupContainer.find("button.delete-group, button.reset-group").remove();
                        // Add section for displaying and editing the parent path
                        addParentPathSectionToForm(groupId, groupContainer, form);
                    }
                });
            }
        }
        
        /**
         * Code for page which shows the group membership form for adding or updating members
         */
        if ($("div.member-form-container").length){
            // Get member container, memberId, username, and groupId
            var memberContainer = $("div.member-form-container");
            var memberId = memberContainer.data("member-id");
            var memberUsername = memberContainer.data("member-username");
            var groupId = memberContainer.data("group-id");
            
            // If memberId exists, update the member
            if (memberId){
                // Load member submission
                K.load({
                    path: bundle.spaceLocation() + "/submissions/" + memberId, 
                    container: memberContainer,
                    updated: function(data){
                        // When updated, update user attributes
                        updateUserMembership(data.submission.values["Username"], 
                                data.submission.values["Group Id"], 
                                data.submission.values["Status"] == "active");
                        // Redirect back to list of members
                        location.href = $("a.return-to-current-group").attr("href") + "#members";
                    },
                    loaded: function(form){
                        // Bind event for reset button to refresh the page
                        $(form.element()).find("button.cancel-membership").on("click", function(){
                            location.href = $("a.return-to-current-group").attr("href") + "#members";
                        });
                    }
                });
            }
            // If memberId doesn't exist, create a new member
            else {
                // Load a new member form
                K.load({
                    path: bundle.kappLocation() + "/group-membership", 
                    container: memberContainer,
                    created: function(data){
                        // When created, update user attributes
                        updateUserMembership(data.submission.values["Username"], 
                                data.submission.values["Group Id"], 
                                data.submission.values["Status"] == "active");
                        // Redirect back to list of members
                        location.href = $("a.return-to-current-group").attr("href") + "#members";
                    },
                    loaded: function(form){
                        // Pre-populate the groupId field
                        form.getFieldByName("Group Id").value(groupId);
                        // Bind event for reset button to refresh the page
                        $(form.element()).find("button.cancel-membership").on("click", function(){
                            location.href = $("a.return-to-current-group").attr("href") + "#members";
                        });
                    }
                });
            }
        }
        
        /**
         * Event handler for delete button on member table
         */
        $("table.members-table").on("click", "a.delete", function(e){
            // Store instance of delete button as self
            var self = $(this);
            // Get row of member
            var memberRow = self.closest("tr");
            // Get membershipId, username, and groupId
            var membershipId = memberRow.find("td.username").data("membership-id");
            var membershipUsername = memberRow.find("td.username").text();
            var groupId = self.closest("table").data("group-id");
            // Create modal to confirm delete
            (new KD.Modal({
                header: "<h3>Confirm Delete</h3>",
                body: "Are you sure you want to delete member " + membershipUsername + "?",
                footer: function(element, actions) {
                    element.addClass("text-right").append(
                        $("<button>", {class: "btn btn-success"}).text("Yes").on("click", actions.accept),
                        $("<button>", {class: "btn btn-link"}).text("Cancel").on("click", actions.dismiss)
                    );
                },
                size: "sm",
                backdrop: true,
                backdropclose: true,
                keyboardclose: true,
                renderCallback: false,
                accept: function(e){
                    // If delete is confirmed, update the membership submission's status to "delete"
                    $.ajax({
                        method: "PUT",
                        url: bundle.apiLocation() + "/submissions/" + membershipId,
                        dataType: "json",
                        data: JSON.stringify({values: {"Status": "delete"}}),
                        contentType: "application/json",
                        success: function(data, textStatus, jqXHR){
                            // On success, update user attributes
                            updateUserMembership(membershipUsername, groupId, false);
                            // Remove row from table
                            memberRow.remove();
                        },
                        error: function(jqXHR, textStatus, errorThrown){
                            // On error, show error in modal
                            (new KD.Modal({
                                header: "<h3>Error</h3>",
                                body: "Failed to delete the member " + membershipUsername + ".",
                                footer: function(element, actions) {
                                    element.addClass("text-right").append(
                                        $("<button>", {class: "btn btn-success"}).text("OK").on("click", actions.dismiss)
                                    );
                                },
                                size: "sm",
                                backdrop: true,
                                backdropclose: true,
                                keyboardclose: true,
                                renderCallback: false
                            })).show();
                        }
                    });
                }
            })).show();
            // Blur delete button
            self.blur();
        });
    });

    /*----------------------------------------------------------------------------------------------
     * COMMON INIALIZATION 
     *   This code is executed when the Javascript file is loaded
     *--------------------------------------------------------------------------------------------*/
    // Ensure the BUNDLE global object exists
    bundle = typeof bundle !== "undefined" ? bundle : {};
    // Create namespace for Admin Datastore
    bundle.adminGroupManagement = bundle.adminGroupManagement || {};
    // Create a scoped alias to simplify references to your namespace
    var datastore = bundle.adminGroupManagement;

    /*----------------------------------------------------------------------------------------------
     * COMMON FUNCTIONS
     *--------------------------------------------------------------------------------------------*/
    
    /**
     * Function for adding the parent path to the group form
     */
    function addParentPathSectionToForm(groupId, groupContainer, form){
        // Get parent path and delimiter
        var parentPathString = groupContainer.data("parent-path");
        var parentPathDelimiter = groupContainer.data("path-delimiter");
        // Split parent path into an array
        var parentPath = parentPathString.split(parentPathDelimiter);
        // Get json data of all groups
        var groupData = JSON.parse($("div.group-data-json").text());
        // Get current group object
        var group = _.find(groupData, {id: groupId});
        // if group doesn't exist, we're creating a new group
        if (!group){
            // Create empty object to prevent null pointers
            group = {};
            // If parent id is specified in the params, pre-set the parent id
            if (groupContainer.data("parent-id")){
                group.parent = groupContainer.data("parent-id");
                form.getFieldByName("Parent").value(group.parent);
            }
        }
        // Build parent path view
        var pathView = $("<div>").append(parentPathString)
                .append(parentPathDelimiter)
                .append($("<strong>", {class: "current-group-name"}).append(group.name));
        // Create container to hold editable parent path
        var pathContainer = $("<div>", {class: "parent-path-item"});
        // Prepend Parent Path to the top of the group form
        $(form.element()).prepend($("<div>", {class: "form-group"})
                .append($("<label>", {class: "field-label"}).text("Parent Path")
                        .append($("<span>", {class: "fa fa-pencil fa-fw edit-parent-path"})
                                // Event handler for clicking edit button of parent path field
                                .on("click", function(e){
                                    // Remove the view only path and the edit button
                                    pathView.remove();
                                    $(this).remove();
                                    // Show the editable path
                                    makeParentPathSectionEditable(group, groupData, pathContainer, parentPath, parentPathDelimiter, form);
                                })))
                .append(pathView)
                .append(pathContainer));
        
        // Bind text changes in Name field to update name in parent path section in real time
        $(form.getFieldByName("Name").element()).on("keyup", function(){
            $("strong.current-group-name").text($(this).val().trim());
        });
        // Bind event for reset button to refresh the page
        $(form.element()).find("button.reset-group").on("click", function(){
            location.reload();
        });
        // Bind event for cancel button to go back to group listing page or parent page if adding subgroup
        $(form.element()).find("button.cancel-group").on("click", function(){
            // If we were adding a subgroup, go back to parent group page
            if (groupContainer.data("parent-id")){
                location.href = $("a.return-to-groups-console").attr("href") + "&page=groups/group&group=" + groupContainer.data("parent-id") + "#subgroups";
            }
            // Go to groups console page
            else {
                location.href = $("a.return-to-groups-console").attr("href");
            }
        });
    }
    
    function makeParentPathSectionEditable(group, groupData, pathContainer, parentPath, parentPathDelimiter, form){
        // Get parent of current group
        var iter = _.find(groupData, {id: group.parent});
        // Array to store all parents
        var parents = new Array();
        // Populate array of parents going up the tree
        while (iter != null){
            parents.unshift(iter);
            iter = _.find(groupData, {id: iter.parent});
        }
        // Create container variable for current level of parent path
        var currentContainer = pathContainer;
        // Iterate through each parent to build editable parent path structure of nested divs
        _.each(parents, function(parentGroup){  
            // Create a select dropdown, and add to current container
            var select = $("<select>").appendTo(currentContainer).after($("<span>", {class: "fa fa-times remove-parent-path"}));
            // Iterate through all data for current level (where group's parent matches parent we're iterating over, excluding this group)
            _.each(_.reject(_.where(groupData, {parent: parentGroup.parent}), {id: group.id}), function(g){
                // Create option for the dropdown of this group
                select.append($("<option>", {value: g.id}).text(g.name)); 
            });
            // Build the next div container, which will be nested under the current container
            var nextContainer = $("<div>", {class: "parent-path-item", "data-path-delimiter": parentPathDelimiter});
            // Nest the next container
            currentContainer.append(nextContainer);
            // Set current container to the next one, to prepare for next iteration
            currentContainer = nextContainer;
            // Select the current group for this level of parent path
            select.find("option[value='" + parentGroup.id + "']").prop("selected", true);
            // Add attribute to specify whether current selection in the dropdown has subgroups
            select.attr("data-has-subgroups", _.some(groupData, function(g){
                return g.parent == select.val() && g.id != group.id;
            }));
        });
        
        // Add button for adding another parent level, and name of current group
        currentContainer.addClass("current-group-item")
                .append($("<button>", {class: "btn btn-xs btn-subtle"})
                        .append($("<span>", {class: "fa fa-plus fa-fw"}))
                        .append("Add Parent"))
                .append($("<div>", {class: "parent-path-item"}).append($("<strong>", {class: "current-group-name"}).append(form.getFieldByName("Name").value())));
        
        /**
         * Event handler which updates the hierarchy when any dropdown is changed in the parent path
         */ 
        pathContainer.parent().on("change", "select", function(e){
            // Get the container of the parent level that was updated
            var thisContainer = $(this).closest("div.parent-path-item");
            // Detach the container that holds the add parent button and current group name
            var currentGroupContainer = thisContainer.find("div.current-group-item").detach();
            // Remove all children of parent level that was changed
            thisContainer.children("div.parent-path-item").remove();
            // Add the container with button and current group name back as a child of the parent level that was changed
            thisContainer.append(currentGroupContainer);
            // Find the select dropdown of the now immediate parent
            var newParentSelect = currentGroupContainer.parent("div.parent-path-item").children("select");
            // Check if parent has subgroups that could be valid parents
            newParentSelect.attr("data-has-subgroups", _.some(groupData, function(g){
                return g.parent == newParentSelect.val() && g.id != group.id;
            }));
            // If parent select exists (ie: we're not the root group) set the parent group's id into the Parent field
            if (newParentSelect.length){
                form.getFieldByName("Parent").value(newParentSelect.val());
            }
            // Otherwise set parent field to empty string
            else {
                form.getFieldByName("Parent").value("");
            }
        /**
         * Event handler for removing a portion of the parent path
         */
        }).on("click", "span.remove-parent-path", function(){
            // Get the container of the parent level that will be removed
            var thisContainer = $(this).closest("div.parent-path-item");
            // Detach the container that holds the add parent button and current group name
            var currentGroupContainer = thisContainer.find("div.current-group-item").detach();
            // Get the parent of the level that will be removed
            var newParentContainer = thisContainer.parent();
            // Remove the selected level and all of it's children
            thisContainer.remove();
            // Add the container with button and current group name back as a child of the current parent level
            newParentContainer.append(currentGroupContainer);
            // Find the select dropdown of the now immediate parent
            var newParentSelect = newParentContainer.children("select");
            // If parent select exists (ie: we're not the root group) set the parent group's id into the Parent field
            if (newParentSelect.length){
                form.getFieldByName("Parent").value(newParentSelect.val());
            }
            // Otherwise set parent field to empty string
            else {
                form.getFieldByName("Parent").value("");
            }
        /**
         * Event handler for adding a parent level
         */
        }).on("click", "button", function(e){
            // Get container that holds the add parent button and current group name 
            var currentGroupContainer = $(this).closest("div.current-group-item");
            // Get parent of current group container
            var currentParentContainer = currentGroupContainer.parent();
            // Find the id of the current parent if one exists
            var currentParentId = currentParentContainer.find("select").val() || null;
            // Get the data whose parent is the current parent
            var newParentData = _.reject(_.where(groupData, {parent: currentParentId}), {id: group.id});
            // Build new container to store new parent
            var newParentContainer = $("<div>", {class: "parent-path-item", "data-path-delimiter": parentPathDelimiter});
            // Add select dropdown to new parent
            var newParentSelect = $("<select>").appendTo(newParentContainer).after($("<span>", {class: "fa fa-times remove-parent-path"}));
            // Add data to new parent dropdown
            _.each(newParentData, function(group){
                newParentSelect.append($("<option>", {value: group.id}).text(group.name)); 
            });
            // Add new parent container to the former immediate parent container
            currentParentContainer.append(newParentContainer);
            // Move current group container to the new parent container
            newParentContainer.append(currentGroupContainer);
            // Check if parent has subgroups that could be valid parents
            newParentSelect.attr("data-has-subgroups", _.some(groupData, function(g){
                return g.parent == newParentSelect.val() && g.id != group.id;
            }));
            // Set Parent field to the new parent that was added
            form.getFieldByName("Parent").value(newParentSelect.val());
        });
    }
    
    /**
     * Method for deleting a group. Sets the group submission's status to delete.
     */
    function deleteGroup(groupId, groupContainer){
        // Submit ajax call to change status to "delete"
        $.ajax({
            method: "PUT",
            url: bundle.apiLocation() + "/submissions/" + groupId,
            dataType: "json",
            data: JSON.stringify({values: {"Status": "delete"}}),
            contentType: "application/json",
            beforeSend: function(jqXHR, settings){
                // Empty the group container and add deleting message before starting ajax call
                groupContainer.empty().append($("<div>", {class: "alert alert-info"})
                        .append($("<span>", {class: "fa fa-spinner fa-spin"}))
                        .append("Deleting"));
            },
            success: function(data, textStatus, jqXHR){
                // On success, return to group listing page
                location.replace($("a.return-to-groups-console").attr("href"));
            },
            error: function(jqXHR, textStatus, errorThrown){
                // On error, show error
                (new KD.Modal({
                    header: "<h3>Error</h3>",
                    body: "Failed to delete the group.",
                    footer: function(element, actions) {
                        element.addClass("text-right").append(
                            $("<button>", {class: "btn btn-success"}).text("OK").on("click", actions.dismiss)
                        );
                    },
                    size: "sm",
                    backdrop: true,
                    backdropclose: true,
                    keyboardclose: true,
                    renderCallback: false,
                    dismiss: function(){
                        // On dismiss of error, reload the page
                        location.reload();
                    }
                })).show();
            }
        });
    }
    
    /**
     * Updates the user's Group attributes to add/remove the appropriate groups based on membership
     */
    function updateUserMembership(username, groupId, isActive){
        // Perform ajax call to api to get the user's attributes
        $.ajax({
            method: "GET",
            url: bundle.apiLocation() + "/users/" + username + "?include=attributes",
            dataType: "json",
            contentType: "application/json",
            success: function(data, textStatus, jqXHR){
                // Create flag for checking if attributes were changed
                var saveRequired = false;
                // Get attributes array, or create a new one if one didn't already exist
                var attributes = data.user.attributes || [];
                // Find Group attributes object from attributes array
                var groupAttributes = _.find(attributes, {name: "Group"});
                // If Group attribute exists, check if it needs to be updated
                if (groupAttributes){
                    // If membership is active and doesn't exist
                    if (isActive && !_.contains(groupAttributes.values, groupId)){
                        // Add the group id to the user
                        groupAttributes.values.push(groupId);
                        // Set flag to true to perform save
                        saveRequired = true;
                    }
                    // If membership is not active but exists, remove it
                    else if (!isActive && _.contains(groupAttributes.values, groupId)){
                        // Remove the group Id from the user
                        groupAttributes.values = _.without(groupAttributes.values, groupId);
                        // Set flag to true to perform save
                        saveRequired = true;
                    }
                }
                // If Group attributes don't exist but membership is active and needs to be added
                else if (isActive){
                    // Add a new Group attribute object to attributes array
                    attributes.push({
                        name: "Group",
                        values: [groupId]
                    });
                    // Set flag to true to perform save
                    saveRequired = true;
                }
                // If save is required (based on flag that was set), update the user attributes using the api
                if (saveRequired){
                    $.ajax({
                        method: "PUT",
                        url: bundle.apiLocation() + "/users/" + username + "?include=attributes",
                        dataType: "json",
                        data: JSON.stringify({attributes: attributes}),
                        contentType: "application/json",
                        success: function(data, textStatus, jqXHR){},
                        error: function(jqXHR, textStatus, errorThrown){
                            // On error, console log an error. We've already redirected so there's nothing we can do.
                            console.log("Error Updating User Group Attribute: Save Failed [" + errorThrown + "]");
                        }
                    });
                }
            },
            error: function(jqXHR, textStatus, errorThrown){
                // Console log an error if we couldn't find the user
                console.log("Error Updating User Group Attribute: User Not Found [" + errorThrown + "]");
            }
        });
    }
    
})($, _);