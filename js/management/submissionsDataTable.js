/**
 * submissionsDataTable.js is a helper for build a DataTable to display submissions with server side pagination.
 * 
 */
(function($, _) {
    /*----------------------------------------------------------------------------------------------
     * DOM MANIPULATION AND EVENT REGISTRATION
     *   This section is executed on page load to register events and otherwise manipulate the DOM.
     *--------------------------------------------------------------------------------------------*/  
    $(function() {
        // Initialize table for recent submissions
        $("table[data-submissions-data-table]").each(function(i,table){
            bundle.submissionsDataTable.load($(table));
        });

        $("[data-submissions-data-table-state-reset]").each(function(i,element){
            var stateResetValues = $(element).data("submissions-data-table-state-reset");
            if (stateResetValues) {
                stateResetValues = stateResetValues.split(",");
            }
            var re = new RegExp("^DataTables_(" + stateResetValues.join("|") + ").*?" 
                         + window.location.pathname.replace(/\/$/, "") + ".*");
            // Clear DataTables attribute from local storage to remove save state
            Object.keys(window.localStorage).forEach(function(key){
                if (re.test(key)) {
                    window.localStorage.removeItem(key);
                }
            });

        });
    });

    /*----------------------------------------------------------------------------------------------
     * COMMON INIALIZATION 
     *   This code is executed when the Javascript file is loaded
     *--------------------------------------------------------------------------------------------*/
    // Ensure the BUNDLE global object exists
    bundle = typeof bundle !== "undefined" ? bundle : {};
    // Create namespace for Admin Kapp
    bundle.submissionsDataTable = bundle.submissionsDataTable || {};
    // Create a scoped alias to simplify references to your namespace
    var sdt = bundle.submissionsDataTable;
    
    _.templateSettings = { interpolate: /\{\{(.+?)\}\}/g };

    /*----------------------------------------------------------------------------------------------
     * COMMON FUNCTIONS
     *--------------------------------------------------------------------------------------------*/
    
    sdt.load = function(table, previousPage, nextPage){
        // Destroy table if it already exists and show loading message
        if ($.fn.DataTable.isDataTable(table)){
            table.DataTable().destroy();
            table.find("tbody").remove();
            table.append("<tbody><tr><td class=\"text-center\"><span class=\"fa fa-spinner fa-spin\"></span>Loading</td><tbody>");
        }        
        
        // Build options and set renderers
        var options = sdt.buildOptions(table, previousPage, nextPage);
        sdt.render.addRenderers(options.columns);
        
        // Build DataTable
        table.DataTable(options);
    };

    sdt.buildURL = function(table){
        return bundle.apiLocation() + table.data("source")
            + "?include=" + table.data("source-include")
            + (table.data("source-query") ? "&" + table.data("source-query") : "")
            + "&limit=" + (table.data("source-limit") || 25)
            + (table.data("pageToken") ? "&pageToken=" + table.data("pageToken") : "");
    };
    
    sdt.buildColumns = function(table){
        return table.find("thead tr th").map(function(i, th){
            return {
                title: $(th).text().trim(),
                data: $(th).data("data"),
                renderType: $(th).data("render-type")
            }
        });
    };
    
    sdt.buildOptions = function(table, previousPage, nextPage){
        var options = {
            columns: sdt.buildColumns(table),
            ajax: {
                dataSrc: "submissions",
                url: sdt.buildURL(table)
            },
            responsive: true,
            pageLength: table.data("source-limit") || 25,
            pagingType: "server_side",
            dom: "tp",
            order: [[table.data("order-column") || 0, table.data("order-direction") || "asc"]],
            stateSave: table.data("state-save") === false ? false : true,
            stateDuration: 1800, // 30 minute state duration
            // Load the pageToken and previous pageTokens from the state of the table
            stateLoadParams: function (settings, data) {
                // If we want the previous page, pop the last pageToken and set as the current pageToken
                if (previousPage){
                    var previousPages = data.previousPageTokens || [];
                    table.data("pageToken", previousPages.pop());
                    table.data("previousPageTokens", previousPages);
                }
                // If we want the next page, push the current pageToken to the previous pageTokens stack
                // and set the nextPageToken as the current pageToken
                else if (nextPage){
                    var previousPages = data.previousPageTokens || [];
                    previousPages.push(data.pageToken || "");
                    table.data("pageToken", table.data("nextPageToken"));
                    table.data("previousPageTokens", previousPages);
                }
                else {
                    table.data("pageToken", data.pageToken || "");
                    table.data("previousPageTokens", data.previousPageTokens || []);
                }
                // Rebuild url since pageToken may have changed
                settings.ajax.url = sdt.buildURL(table);
            },
            // Save the pageToken and previous pageTokens along with the state of the table
            stateSaveParams: function (settings, data) {
                data.pageToken = table.data("pageToken") || "";
                data.previousPageTokens = table.data("previousPageTokens") || [];
            },
            initComplete: function(settings, json){
                table.data("nextPageToken", json.nextPageToken || null);
            }
        };
        if (table.data("toggle-columns")){
            options.buttons = options.buttons || []; 
            options.buttons.push({
                extend: "colvis",
                text: table.data("toggle-columns") + " <span class='fa fa-caret-down'></span>",
                collectionLayout: 'column-visibility-layout',
                className: "column-visibility-button btn-subtle",
                columns: ".visibility-toggle"
            });
            if (options.dom.indexOf("B") < 0){
                options.dom = "B" + options.dom;
            }
        }
        return options;
    };
    
    
    /**
     * Define renderers for various field types and properties of a submission
     */
    sdt.render = sdt.render || {};
    sdt.render.addRenderers = function(columns){
        $.each(columns || [], function(i, col){
            switch(col.renderType){
            case "date":
                col.render = sdt.render.moment("date", "ll", bundle.config.userLocale);
                break;
            case "datetime":
                col.render = sdt.render.moment("datetime", "lll", bundle.config.userLocale);
                break;
            case "time":
                col.render = sdt.render.moment("time", "LT", bundle.config.userLocale);
                break;
            case "checkbox":
                col.render = sdt.render.checkbox();
                break;
            case "attachment":
                col.render = sdt.render.attachment(col.data);
                break;
            case "text":
                col.render = sdt.render.text();
                break;
            case "dropdown":
                col.render = sdt.render.text();
                break;
            case "radio":
                col.render = sdt.render.text();
                break;
            case "submissionManagementLink":
                col.render = sdt.render.submissionManagementLink();
                break;
            case "valueSubmissionManagementLink":
                col.render = sdt.render.valueSubmissionManagementLink();
                break;
            case "statusLabel":
                col.render = sdt.render.statusLabel();
                break;
            case "submitted":
                col.render = sdt.render.submitted();
                break;
            default:
                col.render = sdt.render.text();
            }
        });
    };
    
    // Renderer for formatting dates, times, and datetimes.
    sdt.render.moment = function(from, to, locale){
        switch(from) {
            case "datetime":
                from = "YYYY-MM-DDTHH:mm:ssZ";
                break;
            case "time":
                from = "HH:mm";
                break;
            case "date":
                from = "YYYY-MM-DD";
                break;
        }
        // Defaults if arguments are missing
        if (from == null){
            from = "YYYY-MM-DD";
        }
        if (to == null){
            to = from;
        }
        if ( locale == null ){
            locale = "en";
        }
        return function ( d, type, row ){
            if (type === "export" || d == null || d.length <= 0){
                return d;
            }
            var m = window.moment(d, from, locale, true);
            // Order and type get a number value from Moment, everything else
            // sees the rendered value
            return m.format(type === "sort" || type === "type" ? "x" : to);
        };
    };

    // Renderer for formatting checkboxes
    sdt.render.checkbox = function(){
        return function ( d, type, row ){
            if (type === "export"){
                return $.htmlEncode(d);
            }
            var data = null;
            if ($.isArray(d)){
                data = d;
            }
            else if (d){
                try {
                    data = JSON.parse(d);
                } catch (e){}
            }
            if (data){
                var result = "<ul>";
                _.each(data, function(v, i){
                    result += "<li>" + $.htmlEncode(v) + "</li>"
                });
                result += "</ul>";
                return result;
            }
            return d;
        };
    };

    // Renderer for formatting attachments.
    sdt.render.attachment = function(fieldName){
        return function ( d, type, row ){
            if (type === "export"){
                return d;
            }
            var data = null;
            if ($.isArray(d)){
                data = d;
            }
            else if (d){
                try {
                    data = JSON.parse(d);
                } catch (e){}
            }
            if (data){
                var result = "";
                for (var i = 0; i < data.length; i++){
                    if (result.length > 0){
                        result += "<br>";
                    }
                    if (type === "display"){
                        var url = bundle.spaceLocation()
                                + "/submissions/"
                                + row.id
                                + "/files/"
                                + encodeURIComponent(fieldName.split(".").pop())
                                + "/" + i + "/"
                                + encodeURIComponent(data[i].name);
                        result += "<a href=\"" + url + "\">" + $.htmlEncode(data[i].name) + "</a>";
                    }
                    else {
                        result += data[i].name;
                    }
                }
                return result;
            }
            return d;
        };
    };

    // Renderer for formatting text (encode any HTML).
    sdt.render.text = function(){
        return function ( d, type, row ){
            return $.htmlEncode(d || "");
        };
    };
    
    // Renderer for formatting the column as a link to the admin management's submission activity page
    sdt.render.submissionManagementLink = function(){
        return function ( d, type, row ){
            if (d == null || d.length <= 0 || type === "sort" || type === "type"){
                return d;
            }
            return "<a href='" + bundle.kappLocation(bundle.config.adminKappSlug || "admin") + "/" 
                + "management?page=management/submission" 
                + "&id=" + row.id + "'>"+ d + "</a>";
        };
    };
    
    // Renderer for formatting the column as a link to the admin management's submission activity page using the column value as the id
    sdt.render.valueSubmissionManagementLink = function(){
        return function ( d, type, row ){
            if (d == null || d.length <= 0 || type === "sort" || type === "type"){
                return d;
            }
            return "<a href='" + bundle.kappLocation(bundle.config.adminKappSlug || "admin") + "/" 
            + "management?page=management/submission" 
            + "&id=" + d + "'>"+ d + "</a>";
        };
    };
    
    // Renderer for formatting status (or coreState if status field doesn't exist) 
    sdt.render.statusLabel = function(){
        return function ( d, type, row ){
            var status, statusClass;
            if (bundle.config.submission && bundle.config.submission.getStatusClass && bundle.config.submission.getStatus){
                status = bundle.config.submission.getStatus(row);
                statusClass = bundle.config.submission.getStatusClass(row);
            }
            else {
                status = row.values && row.values["Status"] ? row.values["Status"] : row.coreState;
                statusClass = "label-default";
            }
            if (type === "sort" || type === "type"){
                return status;
            }
            return "<label class='label " + statusClass + "'>" + status + "</label>";
        };
    };
    
    // Renderer for formatting submitted column as submittedAt date and submittedBy user link
    sdt.render.submitted = function(){
        return function ( d, type, row ){
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
                            + "?page=profile&username=" + encodeURIComponent(row.submittedBy);
                userInfo += "<a href='" + link + "'>" + row.submittedBy + "</a>";
                return m.fromNow() + userInfo;
            }
        };
    };
    
    /**
     * Custom pagination plugin for the submissions datatable
     * Shows previous and next buttons, as well as the current page number
     */
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
                        sdt.load($(oSettings.nTable), true, false);
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
                        sdt.load($(oSettings.nTable), false, true);
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