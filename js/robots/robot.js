/* JS Specific to the Robot Console */
(function($, _) {
    /*----------------------------------------------------------------------------------------------
     * DOM MANIPULATION AND EVENT REGISTRATION 
     *   This section is executed on page load to register events and otherwise manipulate the DOM.
     *--------------------------------------------------------------------------------------------*/
    $(function() {
        
        $("table#robots-table").each(function(i,table){
            robot.loadRobotList($(table));
        });

        $("div.robot-form-container").each(function(i,container){
            robot.loadRobotForm($(container));
        });
        
        $("table#robot-schedules-table").each(function(i,table){
            robot.loadRobotSchedulesList($(table));
        });

        $("table#robot-executions-table").each(function(i,table){
            robot.loadRobotExecutionsList($(table));
        });
        
        $("div.robot-schedule-form-container").each(function(i,container){
            robot.loadScheduleForm($(container));
        });

        $("table#robot-schedule-executions-table").each(function(i,table){
            robot.loadRobotScheduleExecutionsList($(table));
        });
        
        $("div.robot-execution-form-container").each(function(i,container){
            robot.loadExecutionForm($(container));
        });

    });

    /*----------------------------------------------------------------------------------------------
     * COMMON INIALIZATION 
     *   This code is executed when the Javascript file is loaded
     *--------------------------------------------------------------------------------------------*/
    // Ensure the BUNDLE global object exists
    bundle = typeof bundle !== "undefined" ? bundle : {};
    // Create namespace for Admin Kapp
    bundle.adminRobots = bundle.adminRobots || {};
    // Create a scoped alias to simplify references to your namespace
    var adminRobots = bundle.adminRobots;
    
    // Private namesapce for robots
    var robot = new Object();
    robot.consoleSlug = "robots";
    _.templateSettings = { interpolate: /\{\{(.+?)\}\}/g };

    /*----------------------------------------------------------------------------------------------
     * COMMON FUNCTIONS
     *--------------------------------------------------------------------------------------------*/
    
    robot.loadRobotList = function(table){
        robot.robotsTable = table;
        $.ajax({
            method: "GET",
            url: bundle.kappLocation() + "?partial=robots/robotData.json&data=robot-definitions",
            dataType: "json",
            contentType: "application/json",
            success: function(data){
                var options = $.extend({}, data, {
                    responsive: true,
                    stateSave: false,
                    pageLength: 25
                });
                bundle.admin.addDataTableRenderers(options.columns, {
                    actions: function(d, type, row){
                        var url = bundle.kappLocation() + "/" + robot.consoleSlug + "?page=robots/robot&robot=" + row.ID;
                        return $("<div>", {class: "btn-group"})
                                .append($("<a>", {href: url, class: "btn btn-xs btn-default"})
                                    .append($("<span>", {class: "fa fa-pencil fa-fw"})))
                                .get(0).outerHTML;
                    }
                });
                robot.robotsDataTable = table.DataTable(options);
            },
            error: function(jqXHR, textStatus, errorThrown){
                try { 
                    errorThrown = JSON.parse(jqXHR.responseText).error; 
                } catch(e){}
                table.empty().notifie({
                    message: "Failed to load robots.<br>" + errorThrown
                });
            }
        });
    };
    
    robot.loadRobotForm = function(container){
        var id = container.data("robot-submission-id");
        
        // If robot exists, load submission to edit
        if (id){
            // Load the robot submission
            K.load({
                path: bundle.spaceLocation() + "/submissions/" + id, 
                container: container,
                updated: function(data){
                    // On update refresh the page
                    location.reload();
                },
                loaded: function(form){
                    // On load, remove the cancel button which is only used on the add new robot page
                    container.find("button.cancel-robot").remove();
                    // On load, enable reset button to reload page
                    $(form.element()).find("button.reset-robot").on("click", function(){
                        location.reload();
                    });
                    // If robot has schedules, make delete button show an error
                    if (container.data("has-schedules")){
                        // Add event to show alert when delete is clicked that you can't delete a robot with schedules
                        container.on("click", "button.delete-robot", function(e){
                            (new KD.Modal({
                                header: "<h3>Not Allowed</h3>",
                                body: "You can not delete a robot which has schedules. Please delete all schedules first.",
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
                    // If robot doesn't have schedules, enable delete robot button with confirmation
                    else {
                        // Add event for handling delete of robot
                        container.on("click", "button.delete-robot", function(e){
                            (new KD.Modal({
                                header: "<h3>Confirm Delete</h3>",
                                body: "Are you sure you want to delete this robot?",
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
                                    // On accept of confirmation, delete the robot
                                    robot.deleteSubmission(id, container, "robot");
                                }
                            })).show();
                            // Blur delete button
                            $(this).blur();
                        });
                    }
                }
            });
            
            /**
             * On load of page, if hash exists in url, open the appropriate tab of the robot page
             */
            if ($("div.robots-tab-content").length){
                // Open tab based on hash if one exists
                $("a[href='"+location.hash+"']").tab('show');
            }
        }
        // Otherwise load empty form to create new robot
        else {
            K.load({
                path: bundle.kappLocation() + "/robot-definitions", 
                container: container,
                created: function(data){
                    // When group is created, redirect to edit group page
                    location.replace($("a.return-to-robots-console").attr("href") + "?page=robots/robot&robot=" + data.submission.id);
                },
                loaded: function(form){
                    // Remove delete button since group doesn't yet exist, and reset button
                    container.find("button.delete-robot, button.reset-robot").remove();
                    // Bind event for cancel button to go back to robot listing page
                    $(form.element()).find("button.cancel-robot").on("click", function(){
                        location.href = $("a.return-to-robots-console").attr("href");
                    });
                }
            });
        }
    };
    
    robot.loadRobotSchedulesList = function(table){
        robot.robotSchedulesTable = table;
        $.ajax({
            method: "GET",
            url: bundle.kappLocation() + "?partial=robots/robotData.json&data=robot-schedules&robotId=" + robot.robotSchedulesTable.data("robot-id"),
            dataType: "json",
            contentType: "application/json",
            success: function(data){
                var options = $.extend({}, data, {
                    responsive: true,
                    stateSave: false,
                    pageLength: 25
                });
                bundle.admin.addDataTableRenderers(options.columns, {
                    actions: function(d, type, row){
                        var url = bundle.kappLocation() + "/" + robot.consoleSlug + "?page=robots/schedule&schedule=" + row.ID + "&robot=" + robot.robotSchedulesTable.data("robot-submission-id");
                        return $("<div>", {class: "btn-group"})
                                .append($("<a>", {href: url, class: "btn btn-xs btn-default"})
                                    .append($("<span>", {class: "fa fa-pencil fa-fw"})))
                                .get(0).outerHTML;
                    }
                });
                robot.robotSchedulesDataTable = table.DataTable(options);
            },
            error: function(jqXHR, textStatus, errorThrown){
                try { 
                    errorThrown = JSON.parse(jqXHR.responseText).error; 
                } catch(e){}
                table.empty().notifie({
                    message: "Failed to load schedules.<br>" + errorThrown
                });
            }
        });
    };
    
    robot.loadRobotExecutionsList = function(table){
        var url = function(pageSize, pageToken){
            return bundle.kappLocation() + "?partial=robots/robotData.json&data=robot-executions&pageSize=" + pageSize  
                        + (pageToken ? "&pageToken=" + pageToken : "") 
                        + "&robotId=" + table.data("robot-id");
        };
        robot.loadRobotExecutionsListPaginated(table, url, 25);
    };
    
    robot.loadScheduleForm = function(container){
        var id = container.data("robot-schedule-id");
        
        // If robot exists, load submission to edit
        if (id){
            // Load the robot submission
            K.load({
                path: bundle.spaceLocation() + "/submissions/" + id, 
                container: container,
                updated: function(data){
                    // On update refresh the page
                    location.reload();
                },
                loaded: function(form){
                    // On load, remove the cancel button which is only used on the add new schedule page
                    container.find("button.cancel-schedule").remove();
                    // On load, enable reset button to reload page
                    $(form.element()).find("button.reset-schedule").on("click", function(){
                        location.reload();
                    });
                    // Add event for handling delete of schedule
                    container.on("click", "button.delete-schedule", function(e){
                        (new KD.Modal({
                            header: "<h3>Confirm Delete</h3>",
                            body: "Are you sure you want to delete this schedule?",
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
                                // On accept of confirmation, delete the robot
                                robot.deleteSubmission(id, container, "schedule");
                            }
                        })).show();
                        // Blur delete button
                        $(this).blur();
                    });
                }
            });
            
            /**
             * On load of page, if hash exists in url, open the appropriate tab of the schedule page
             */
            if ($("div.robot-schedules-tab-content").length){
                // Open tab based on hash if one exists
                $("a[href='"+location.hash+"']").tab('show');
            }
        }
        // Otherwise load empty form to create new schedule
        else {
            K.load({
                path: bundle.kappLocation() + "/robot-schedules", 
                container: container,
                created: function(data){
                    // When group is created, redirect to edit group page
                    location.replace($("a.return-to-robots-console").attr("href") + "?page=robots/schedule&schedule=" + data.submission.id + "&robot=" + container.data("robot-submission-id"));
                },
                loaded: function(form){
                    // Add Robot ID to schedule
                    form.getFieldByName("Robot ID").value(container.data("robot-id"));
                    // Remove delete button since group doesn't yet exist, and reset button
                    container.find("button.delete-schedule, button.reset-schedule").remove();
                    // Bind event for cancel button to go back to robot listing page
                    $(form.element()).find("button.cancel-schedule").on("click", function(){
                        location.href = $("a.return-to-robot-definition").attr("href");
                    });
                }
            });
        }
    };
    
    robot.loadRobotScheduleExecutionsList = function(table){
        var url = function(pageSize, pageToken){
            return bundle.kappLocation() + "?partial=robots/robotData.json&data=robot-executions&pageSize=" + pageSize  
                        + (pageToken ? "&pageToken=" + pageToken : "") 
                        + "&robotId=" + table.data("robot-id") 
                        + "&scheduleId=" + table.data("robot-schedule-id");
        };
        robot.loadRobotExecutionsListPaginated(table, url, 25);
    };
    
    robot.loadRobotExecutionsListPaginated = function(table, url, pageSize, pageToken){
        robot.robotExecutionsTable = table;
        pageSize = pageSize || 25;
        $.ajax({
            method: "GET",
            url: url(pageSize, pageToken),
            dataType: "json",
            contentType: "application/json",
            beforeSend: function(){
                if (robot.robotExecutionsDataTable){
                    robot.robotExecutionsDataTable.destroy();
                    robot.robotExecutionsTable.empty().append(
                        $("<tr>").append(
                            $("<td>", {class: "alert alert-info"}).append(
                                $("<span>", {class: "fa fa-spinner fa-spin"}),
                                " Loading"
                            )
                        )
                    );
                }
            },
            success: function(data){
                console.log(data);
                var previousPages = robot.robotExecutionsTable.data("previous-page-token-stack");
                if (!$.isArray(previousPages)){
                    previousPages = new Array();
                }
                robot.robotExecutionsTable.data('current-page-token', pageToken);
                robot.robotExecutionsTable.data('next-page-token', data._nextPageToken);
                var options = $.extend({}, data, {
                    responsive: true,
                    stateSave: false,
                    paging: false,
                    info: false,
                    filter: false,
                    dom: "<'row'<'col-xs-12'<'dataTables_length'>>>t<'row'<'col-xs-5'<'dataTables_info'>><'col-xs-7'<'dataTables_paginate'>>>"
                });
                bundle.admin.addDataTableRenderers(options.columns, {
                    actions: function(d, type, row){
                        var url = bundle.kappLocation() + "/" + robot.consoleSlug + "?page=robots/execution&execution=" + row.ID 
                        + "&robot=" + robot.robotExecutionsTable.data("robot-submission-id");
                        return $("<div>", {class: "btn-group"})
                        .append($("<a>", {href: url, class: "btn btn-xs btn-default"})
                                .append($("<span>", {class: "fa fa-search fa-fw"})))
                                .get(0).outerHTML;
                    }
                });
                robot.robotExecutionsDataTable = table.DataTable(options);
                var wrapper = robot.robotExecutionsTable.parent();
                // Add page length options
            wrapper.find("div.dataTables_length").append($("<label>").append(
                    "Show ",
                    $("<select>", {class: "form-control input-sm executions-table-page-length-select"}).append(
                        $("<option>", {value: "10"}).append("10").prop("selected", pageSize == 10),
                        $("<option>", {value: "25"}).append("25").prop("selected", pageSize == 25),
                        $("<option>", {value: "50"}).append("50").prop("selected", pageSize == 50),
                        $("<option>", {value: "100"}).append("100").prop("selected", pageSize == 100)
                    ).on("change", function(){
                        robot.robotExecutionsTable.data("previous-page-token-stack", new Array());
                        robot.loadRobotExecutionsListPaginated(robot.robotExecutionsTable, url, $(this).val());
                    }),
                    " entries"
                ));
                // Add table info
                wrapper.find("div.dataTables_info").append(
                    "Showing entries " + ((previousPages.length * pageSize) + (data.data.length > 0 ? 1 : 0)) 
                        + " to " + ((previousPages.length * pageSize) + data.data.length)
                );
                // Add pagination
                var previousPageButton = $("<li>", {class: "paginate_button previous"}).append(
                    $("<a>", {href: "javascript:void(0);"}).append(
                        "Previous"
                    )
                );
                if (previousPages.length > 0){
                    previousPageButton.on("click", function(){
                        var previousPageToken = previousPages.pop();
                        robot.robotExecutionsTable.data("previous-page-token-stack", previousPages);
                        robot.loadRobotExecutionsListPaginated(robot.robotExecutionsTable, url, pageSize, previousPageToken);
                    });
                }
                else {
                    previousPageButton.addClass("disabled");
                }
                var nextPageButton = $("<li>", {class: "paginate_button next"}).append(
                    $("<a>", {href: "javascript:void(0);"}).append(
                        "Next"
                    )
                );
                if (data._nextPageToken){
                    nextPageButton.on("click", function(){
                        previousPages.push(pageToken)
                        robot.robotExecutionsTable.data("previous-page-token-stack", previousPages);
                        robot.loadRobotExecutionsListPaginated(robot.robotExecutionsTable, url, pageSize, data._nextPageToken);
                    });
                }
                else {
                    nextPageButton.addClass("disabled");
                }
                wrapper.find("div.dataTables_paginate").append(
                    $("<ul>", {class: "pagination"}).append(
                        previousPageButton,
                        $("<li>", {class: "paginate_button active"}).append(
                            $("<a>", {href: "javascript:void(0);"}).append(
                                previousPages.length + 1
                            )
                        ),
                        nextPageButton
                    )
                );
            },
            error: function(jqXHR, textStatus, errorThrown){
                try { 
                    errorThrown = JSON.parse(jqXHR.responseText).error; 
                } catch(e){}
                table.empty().notifie({
                    message: "Failed to load executions.<br>" + errorThrown
                });
            }
        });
    };
    
    robot.loadExecutionForm = function(container){
        var id = container.data("robot-execution-id");
        // Load submission of execution
        K.load({
            path: bundle.spaceLocation() + "/submissions/" + id, 
            container: container
        });
    };
    
    robot.deleteSubmission = function(id, container, item){
        // Submit ajax call to delete the robot
        $.ajax({
            method: "DELETE",
            url: bundle.apiLocation() + "/submissions/" + id,
            dataType: "json",
            contentType: "application/json",
            beforeSend: function(jqXHR, settings){
                // Empty the group container and add deleting message before starting ajax call
                container.empty().append($("<div>", {class: "alert alert-info"})
                        .append($("<span>", {class: "fa fa-spinner fa-spin"}))
                        .append("Deleting"));
            },
            success: function(data, textStatus, jqXHR){
                // On success, return to group listing page
                location.replace($("a.return-to-robots-console").attr("href"));
            },
            error: function(jqXHR, textStatus, errorThrown){
                // On error, show error
                (new KD.Modal({
                    header: "<h3>Error</h3>",
                    body: "Failed to delete this " + item + ".",
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
    };
    
})($, _);