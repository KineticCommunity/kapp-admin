(function($, _) {
    /*----------------------------------------------------------------------------------------------
     * DOM MANIPULATION AND EVENT REGISTRATION
     *   This section is executed on page load to register events and otherwise manipulate the DOM.
     *--------------------------------------------------------------------------------------------*/  
    $(function() {
        
        // If on console page or on form list page
        if ($("table.form-management-kapps, table.form-management-forms").length){
            // Clear DataTables attribute from local storage to remove save state of datastores
            Object.keys(window.localStorage).forEach(function(key){
                var re = new RegExp("^DataTables_recent-submissions-table.*?" + window.location.pathname.replace(/\/$/, "") + ".*");
                if (re.test(key)) {
                    window.localStorage.removeItem(key);
                }
            });
        }
        
        // Initialize table for recent submissions
        $("table[data-recent-submissions-table]").each(function(i,table){
            formManagement.submissionsTable = $(table);
            formManagement.loadSubmissions(false, false);
        });
        
        // Initialize table of forms
        $("table[data-table-forms-list]").each(function(i,table){
            formManagement.formsTable = $(table);
            formManagement.initializeFormsTable();
        });
        
        /*
         * Initialize DataTable for dom sourced tables
         */
        $("table[data-table-dom]").each(function(i,table){
            var pageLength = $(table).data("page-length") || 25;
            var dom = $(table).data("dom") 
                    || $(table).find("tbody tr").length > pageLength 
                        ? "<'dt-title'f>t<'pull-right'p>i"
                        : ($(table).find("tbody tr").length > 0
                            ? "<'dt-title'f>ti"
                            : "<'dt-title'>t");
            var options = {
                autoWidth: false,
                dom: dom,
                pageLength: pageLength,
                language: {
                    search: "Filter",
                    paginate: {
                        previous: "<",
                        next: ">"
                    }
                },
                drawCallback: function(){
                    $("[data-tooltip]").tooltip();
                }
            };
            if ($(table).data("empty-message")){
                options.language.emptyTable = $(table).data("empty-message");
            }
            $(table).dataTable(options);
            $(table).on("click", "td", function(e){
                if (e.target == this){
                    $(this).closest("tr").toggleClass("full-text");
                }
            });
            $(table).parent().find("div.dt-title").prepend($("<h4>", {class: "pull-left"}).append($(table).data("table-name")));
        });
        
        // Start a discussion for this form
        $("button#start-discussion").on("click", adminFormManagement.startDiscussion);
     });

    /*----------------------------------------------------------------------------------------------
     * COMMON INIALIZATION 
     *   This code is executed when the Javascript file is loaded
     *--------------------------------------------------------------------------------------------*/
    // Ensure the BUNDLE global object exists
    bundle = typeof bundle !== "undefined" ? bundle : {};
    // Create namespace for Admin Kapp
    bundle.adminFormManagement = bundle.adminFormManagement || {};
    // Create a scoped alias to simplify references to your namespace
    var adminFormManagement = bundle.adminFormManagement;
    
    // Private namesapce for system management
    var formManagement = {
        submissionsTableLimit: 25
    };
    _.templateSettings = { interpolate: /\{\{(.+?)\}\}/g };

    /*----------------------------------------------------------------------------------------------
     * COMMON FUNCTIONS
     *--------------------------------------------------------------------------------------------*/
    
    formManagement.initializeFormsTable = function(){
        var options = {
            autoWidth: false,
            dom: "<'row'<'col-sm-6'B><'col-sm-6'f>><'overflow-auto't>",
            paging: false,
            drawCallback: function(){
                $("[data-tooltip]").tooltip();
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
        formManagement.formsTable.dataTable(options);
        formManagement.formsTable.parent()
                                 .find("div.dt-title")
                                 .prepend($("<h4>", {class: "pull-left"})
                                     .append(formManagement.formsTable.data("table-name")));
    };
    
    /**
     * Loads the records for the current datastore and displays them in a DataTable
     * 
     * @param previous boolean specifying if previous page should be fetched.
     * @param next boolean specifying if next page should be fetched.
     */
    formManagement.loadSubmissions = function(previous, next){
        // Destroy table if it already exists
        if ($.fn.DataTable.isDataTable(formManagement.submissionsTable)){
            formManagement.submissionsTable.DataTable().destroy();
            formManagement.submissionsTable.empty();
            formManagement.submissionsTable.append("<tr><td class=\"alert alert-info\"><span class=\"fa fa-spinner fa-spin\"></span>Loading</td>");
        }
        
        var buildURL = function(){
            return bundle.apiLocation() 
                    + "/kapps/" + bundle.adminFormManagement.kappSlug 
                    + "/forms/" + bundle.adminFormManagement.formSlug 
                    + "/submissions"
                    + "?include=details,values,form.attributes,form.kapp.attributes" 
                    + "&timeline=submittedAt&direction=DESC&coreState=Submitted&coreState=Closed"
                    + "&limit=" + formManagement.submissionsTableLimit
                    + (formManagement.submissionsTable.data("pageToken") ? "&pageToken=" + formManagement.submissionsTable.data("pageToken") : "");
        };
        
        var options = {
            columns: [
                {
                    title: "Confirmation #",
                    data: "handle",
                    renderType: "submissionLink" 
                },
                {
                    title: "Submission Label",
                    data: "label"
                },
                {
                    title: "Status",
                    data: "coreState",
                    renderType: "statusLabel"
                },
                {
                    title: "Submitted",
                    data: "submittedAt",
                    renderType: "submissionDetails"
                }
            ],
            order: [[3, "desc"]],
            ajax: {
                dataSrc: "submissions",
                url: buildURL()
            },
            responsive: true,
            pageLength: formManagement.submissionsTableLimit,
            pagingType: "server_side",
            dom: "tp",
            stateSave: true,
            // Load the pageToken and previous pageTokens from the state of the table
            stateLoadParams: function (settings, data) {
                // If we want the previous page, pop the last pageToken and set as the current pageToken
                if (previous){
                    var previousPages = data.previousPageTokens || [];
                    formManagement.submissionsTable.data("pageToken", previousPages.pop());
                    formManagement.submissionsTable.data("previousPageTokens", previousPages);
                }
                // If we want the next page, push the current pageToken to the previous pageTokens stack
                // and set the nextPageToken as the current pageToken
                else if (next){
                    var previousPages = data.previousPageTokens || [];
                    previousPages.push(data.pageToken || "");
                    formManagement.submissionsTable.data("pageToken", formManagement.submissionsTable.data("nextPageToken"));
                    formManagement.submissionsTable.data("previousPageTokens", previousPages);
                }
                else {
                    formManagement.submissionsTable.data("pageToken", data.pageToken || "");
                    formManagement.submissionsTable.data("previousPageTokens", data.previousPageTokens || []);
                }
                // Rebuild url since pageToken may have changed
                settings.ajax.url = buildURL();
            },
            // Save the pageToken and previous pageTokens along with the state of the table
            stateSaveParams: function (settings, data) {
                data.pageToken = formManagement.submissionsTable.data("pageToken") || "";
                data.previousPageTokens = formManagement.submissionsTable.data("previousPageTokens") || [];
            },
            initComplete: function(settings, json){
                formManagement.submissionsTable.data("nextPageToken", json.nextPageToken || null);
            },
            language: {
                emptyTable: "No submissions found."
            }
        };
        bundle.admin.addDataTableRenderers(options.columns, {
            submissionLink: function ( d, type, row ){
                if (d == null || d.length <= 0 || type === "sort" || type === "type"){
                    return d;
                }
                return "<a href='" + bundle.kappLocation() + "/" + bundle.adminFormManagement.consoleSlug
                    + "?page=management/submission" 
                    + "&kapp=" + bundle.adminFormManagement.kappSlug 
                    + "&form=" + bundle.adminFormManagement.formSlug 
                    + "&id=" + row.id 
                    + "'>"
                    + d + "</a>";
            },
            submissionDetails: function ( d, type, row ){
                if (d == null || d.length <= 0){
                    return d;
                }
                var m = window.moment(d, "YYYY-MM-DDTHH:mm:ss.SSSZ", bundle.config.userLocale || "en", true);
                // Order and type get a number value from Moment, everything else sees rendered string
                if (type === "sort" || type === "type"){
                    return m.format("x");
                }
                else {
                    var userInfo = " by ";
                    var link = bundle.spaceLocation()
                                + "?page=user&username=" + encodeURIComponent(row.createdBy);
                    userInfo += "<a href='" + link + "'>" + row.createdBy + "</a>";
                    return m.fromNow() + userInfo;
                }
            },
            statusLabel: function ( d, type, row ){
                if (type === "sort" || type === "type"){
                    return bundle.config.submission.getStatus(row);
                }
                return "<label class='label " + bundle.config.submission.getStatusClass(row) + "'>" + bundle.config.submission.getStatus(row) + "</label>";
            }
        });
        // Build DataTable
        formManagement.submissionsTable.DataTable(options);
    };
    
    adminFormManagement.startDiscussion = function(){
        var self = $(this);
        // Get form
        $.ajax({
            method: "GET",
            url: encodeURI(bundle.apiLocation() + "/kapps/" + bundle.adminFormManagement.kappSlug + "/forms/" + bundle.adminFormManagement.formSlug + "?include=attributes,kapp"),
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
                adminFormManagement.createDiscussion(self, data.form);
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
    
    adminFormManagement.createDiscussion = function(self, form){
        $.ajax({
            method: "POST",
            url: encodeURI(bundle.adminFormManagement.responseUrl + "/api/v1/issues"),
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
                    url: encodeURI(bundle.apiLocation() + "/kapps/" + bundle.adminFormManagement.kappSlug + "/forms/" + bundle.adminFormManagement.formSlug),
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
    
    $.fn.dataTableExt.oPagination.server_side = {
        "fnInit": function ( oSettings, nPaging, fnCallbackDraw ) {
            var pagingUl = $("<ul>", {class: "pagination"}).appendTo($(nPaging));
            var previousLi = $("<li>", {class: "paginate_button previous disabled"}).appendTo(pagingUl);
            var currentLi = $("<li>", {class: "paginate_button active hide"}).appendTo(pagingUl);
            var nextLi = $("<li>", {class: "paginate_button next disabled"}).appendTo(pagingUl);
            
            $("<a>", {href: "javascript:void(0);"})
                .text(oSettings.oLanguage.oPaginate.sPrevious)
                .on("click", function(){
                    if (!$(this).parent().hasClass("disabled")){
                        formManagement.loadSubmissions(true, false);
                        fnCallbackDraw( oSettings );
                    }
                })
                .on("selectstart", function(){
                    return false;
                })
                .appendTo(previousLi);

            $("<a>", {href: "javascript:void(0);"})
                .on("selectstart", function(){
                    return false;
                })
                .appendTo(currentLi);

            $("<a>", {href: "javascript:void(0);"})
                .text(oSettings.oLanguage.oPaginate.sNext)
                .on("click", function(){
                    if (!$(this).parent().hasClass("disabled")){
                        formManagement.loadSubmissions(false, true);
                        fnCallbackDraw( oSettings );
                    }
                })
                .on("selectstart", function(){
                    return false;
                })
                .appendTo(nextLi);
        },
        "fnUpdate": function ( oSettings, fnCallbackDraw ){
            if (oSettings.oSavedState && $.isArray(oSettings.oSavedState.previousPageTokens) && oSettings.oSavedState.previousPageTokens.length > 0){
                $(oSettings.aanFeatures.p).find("li.paginate_button.previous").removeClass("disabled");
            }
            else {
                $(oSettings.aanFeatures.p).find("li.paginate_button.previous").addClass("disabled");
            }
            
            if (oSettings.oSavedState && $.isArray(oSettings.oSavedState.previousPageTokens)){
                $(oSettings.aanFeatures.p).find("li.paginate_button.active a").text(oSettings.oSavedState.previousPageTokens.length + 1);
                $(oSettings.aanFeatures.p).find("li.paginate_button.active").removeClass("hide");
            }
            
            if (oSettings.json && oSettings.json.nextPageToken){
                $(oSettings.aanFeatures.p).find("li.paginate_button.next").removeClass("disabled");
            }
            else {
                $(oSettings.aanFeatures.p).find("li.paginate_button.next").addClass("disabled");
            }
        }
    };

})(jQuery, _);



