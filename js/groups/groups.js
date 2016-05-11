/* JS Specific to the Groups Console */
(function($, _) {
    /*----------------------------------------------------------------------------------------------
     * DOM MANIPULATION AND EVENT REGISTRATION 
     *   This section is executed on page load to register events and otherwise manipulate the DOM.
     *--------------------------------------------------------------------------------------------*/
    $(function() {
        
        $("table.groups-table-flat [data-toggle='tooltip']").tooltip({
            delay: {show: 500, hide: 0 },
            placement: "left"
        });
        
        $("table.groups-table-hierarchy").on("click", "li.group-item.has-subgroups a", function(e){
            e.stopPropagation()
        }).on("click", "li.group-item.has-subgroups", function(e){
            if ($(this).hasClass("open")){
                $(this).removeClass("open");
                $("table.groups-table-hierarchy").find("li[data-group-id='" + $(this).data("group-id") + "']").removeClass("open");
            }
            else {
                $(this).addClass("open");
                $("table.groups-table-hierarchy").find("li[data-group-id='" + $(this).data("group-id") + "']").addClass("open");
            }
        });
        
        $("span.table-view-buttons").on("click", "span", function(e){
            if (!$(this).hasClass("open")){
                $("span.table-view-buttons span, table.groups-table").removeClass("open");
                $(this).addClass("open");
                $("table.groups-table-" + $(this).data("table")).addClass("open");
            }
        });
        
        $("div.table-hierarchy-option").on("click", "button.collapse-all", function(e){
            $("table.groups-table-hierarchy li").removeClass("open");
        }).on("click", "button.expand-all", function(e){
            $("table.groups-table-hierarchy li").addClass("open");
        });
        
        
        if ($("div.group-form-container").length){
            var groupContainer = $("div.group-form-container");
            var groupId = groupContainer.data("group-id");
            
            if (groupId){
                K.load({
                    path: bundle.spaceLocation() + "/submissions/" + groupId, 
                    container: groupContainer,
                    updated: function(data){
                        location.reload();
                    },
                    loaded: function(form){
                        groupContainer.find("button.cancel-group").remove();
                        addParentPathSectionToForm(groupId, groupContainer, form);
                        // Check if group has subgroups
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
                                        deleteGroup(groupId, groupContainer);
                                    }
                                })).show();
                                // Blur delete button
                                $(this).blur();
                            });
                        }
                    }
                });
            }
            else {
                K.load({
                    path: bundle.kappLocation() + "/group", 
                    container: groupContainer,
                    created: function(data){
                        location.replace($("a.return-to-groups-console").attr("href") + "&page=groups/group&group=" + data.submission.id);
                    },
                    loaded: function(form){
                        groupContainer.find("button.delete-group, button.reset-group").remove();
                        addParentPathSectionToForm(groupId, groupContainer, form);
                    }
                });
            }
        }
        
        if ($("div.member-form-container").length){
            var memberContainer = $("div.member-form-container");
            var memberId = memberContainer.data("member-id");
            var memberUsername = memberContainer.data("member-username");
            var groupId = memberContainer.data("group-id");
            
            if (memberId){
                K.load({
                    path: bundle.spaceLocation() + "/submissions/" + memberId, 
                    container: memberContainer,
                    updated: function(data){
                        updateUserMembership(data.submission.values["Username"], 
                                data.submission.values["Group Id"], 
                                data.submission.values["Status"] == "active");
                        location.href = $("a.return-to-current-group").attr("href") + "#members";
                    },
                    loaded: function(form){
                        form.getFieldByName("Group Id").value(groupId);
                        // Bind event for reset button to refresh the page
                        $(form.element()).find("button.cancel-membership").on("click", function(){
                            location.href = $("a.return-to-current-group").attr("href") + "#members";
                        });
                    }
                });
            }
            else {
                K.load({
                    path: bundle.kappLocation() + "/group-membership", 
                    container: memberContainer,
                    created: function(data){
                        updateUserMembership(data.submission.values["Username"], 
                                data.submission.values["Group Id"], 
                                data.submission.values["Status"] == "active");
                        location.href = $("a.return-to-current-group").attr("href") + "#members";
                    },
                    loaded: function(form){
                        form.getFieldByName("Group Id").value(groupId);
                        // Bind event for reset button to refresh the page
                        $(form.element()).find("button.cancel-membership").on("click", function(){
                            location.href = $("a.return-to-current-group").attr("href") + "#members";
                        });
                    }
                });
            }
        }
        
        $("table.members-table").on("click", "a.delete", function(e){
            var self = $(this);
            var memberRow = self.closest("tr");
            var membershipId = memberRow.find("td.username").data("membership-id");
            var membershipUsername = memberRow.find("td.username").text();
            var groupId = self.closest("table").data("group-id");
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
                    $.ajax({
                        method: "PUT",
                        url: bundle.apiLocation() + "/submissions/" + membershipId,
                        dataType: "json",
                        data: JSON.stringify({values: {"Status": "delete"}}),
                        contentType: "application/json",
                        success: function(data, textStatus, jqXHR){
                            updateUserMembership(membershipUsername, groupId, false);
                            memberRow.remove();
                        },
                        error: function(jqXHR, textStatus, errorThrown){
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
        
        if ($("div.groups-tab-content").length){
            // Open tab based on hash if one exists
            $("a[href='"+location.hash+"']").tab('show');
        }
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
    
    function addParentPathSectionToForm(groupId, groupContainer, form){
        var parentPathString = groupContainer.data("parent-path");
        var parentPathDelimiter = groupContainer.data("path-delimiter");
        // Get parent path, split into an array
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
                                .on("click", function(e){
                                    pathView.remove();
                                    $(this).remove();
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
        
        // Event handler which updates the hierarchy when any dropdown is changed
        pathContainer.parent().on("change", "select", function(e){
            var thisContainer = $(this).closest("div.parent-path-item");
            var currentGroupContainer = thisContainer.find("div.current-group-item").detach();
            thisContainer.children("div.parent-path-item").remove();
            thisContainer.append(currentGroupContainer);
            var newParentSelect = currentGroupContainer.parent("div.parent-path-item").children("select");
            newParentSelect.attr("data-has-subgroups", _.some(groupData, function(g){
                return g.parent == newParentSelect.val() && g.id != group.id;
            }));
            if (newParentSelect.length){
                form.getFieldByName("Parent").value(newParentSelect.val());
            }
            else {
                form.getFieldByName("Parent").value("");
            }
        }).on("click", "span.remove-parent-path", function(){
            var thisContainer = $(this).closest("div.parent-path-item");
            var currentGroupContainer = thisContainer.find("div.current-group-item").detach();
            var newParentContainer = thisContainer.parent();
            thisContainer.remove();
            newParentContainer.append(currentGroupContainer);
            var newParentSelect = newParentContainer.children("select");
            if (newParentSelect.length){
                form.getFieldByName("Parent").value(newParentSelect.val());
            }
            else {
                form.getFieldByName("Parent").value("");
            }
        }).on("click", "button", function(e){
            var currentGroupContainer = $(this).closest("div.current-group-item");
            var currentParentContainer = currentGroupContainer.parent();
            var currentParentId = currentParentContainer.find("select").val() || null;
            var newParentData = _.reject(_.where(groupData, {parent: currentParentId}), {id: group.id});
            var newParentContainer = $("<div>", {class: "parent-path-item", "data-path-delimiter": parentPathDelimiter});
            var newParentSelect = $("<select>").appendTo(newParentContainer).after($("<span>", {class: "fa fa-times remove-parent-path"}));
            _.each(newParentData, function(group){
                newParentSelect.append($("<option>", {value: group.id}).text(group.name)); 
            });
            currentParentContainer.append(newParentContainer);
            newParentContainer.append(currentGroupContainer);
            newParentSelect.attr("data-has-subgroups", _.some(groupData, function(g){
                return g.parent == newParentSelect.val() && g.id != group.id;
            }));
            form.getFieldByName("Parent").value(newParentSelect.val());
        });
    }
    
    function deleteGroup(groupId, groupContainer){
        $.ajax({
            method: "PUT",
            url: bundle.apiLocation() + "/submissions/" + groupId,
            dataType: "json",
            data: JSON.stringify({values: {"Status": "delete"}}),
            contentType: "application/json",
            beforeSend: function(jqXHR, settings){
                groupContainer.empty().append($("<div>", {class: "alert alert-info"})
                        .append($("<span>", {class: "fa fa-spinner fa-spin"}))
                        .append("Deleting"));
            },
            success: function(data, textStatus, jqXHR){
                location.replace($("a.return-to-groups-console").attr("href"));
            },
            error: function(jqXHR, textStatus, errorThrown){
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
                        location.reload();
                    }
                })).show();
            }
        });
    }
    
    function updateUserMembership(username, groupId, isActive){
        $.ajax({
            method: "GET",
            url: bundle.apiLocation() + "/users/" + username + "?include=attributes",
            dataType: "json",
            contentType: "application/json",
            success: function(data, textStatus, jqXHR){
                var saveRequired = false;
                var attributes = data.user.attributes || [];
                var groupAttributes = _.find(attributes, {name: "Group"});
                // If Group attribute exists
                if (groupAttributes){
                    // If membership is active and doesn't exist, add it
                    if (isActive && !_.contains(groupAttributes.values, groupId)){
                        groupAttributes.values.push(groupId);
                        saveRequired = true;
                    }
                    // If membership is not active but exists, remove it
                    else if (!isActive && _.contains(groupAttributes.values, groupId)){
                        groupAttributes.values = _.without(groupAttributes.values, groupId);
                        saveRequired = true;
                    }
                }
                // If Group attributes don't exist but membership is active and needs to be added
                else if (isActive){
                    attributes.push({
                        name: "Group",
                        values: [groupId]
                    });
                    saveRequired = true;
                }
                // If save is required, update the user attributes
                if (saveRequired){
                    $.ajax({
                        method: "PUT",
                        url: bundle.apiLocation() + "/users/" + username + "?include=attributes",
                        dataType: "json",
                        data: JSON.stringify({attributes: attributes}),
                        contentType: "application/json",
                        success: function(data, textStatus, jqXHR){},
                        error: function(jqXHR, textStatus, errorThrown){
                            console.log("Error Updating User Group Attribute: Save Failed [" + errorThrown + "]");
                        }
                    });
                }
            },
            error: function(jqXHR, textStatus, errorThrown){
                console.log("Error Updating User Group Attribute: User Not Found [" + errorThrown + "]");
            }
        });
    }
    
})($, _);