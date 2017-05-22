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
        $("head").append("<style type='text/css'>" +
    		"@media (min-width:768px){ .dt-buttons .dropdown .dropdown-menu { min-width: 560px; } } " +
    		"@media (max-width:767px){ .dt-buttons .dropdown .dropdown-menu { width: 80vw; } } " +
    		"</style>");
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

        // Build filter section if necessary
        if (table.data("filter-options-id")){
            console.log("enable filter");
            sdt.enableFilter(table);
        }
    };

    sdt.enableFilter = function(table){
        var filterData = table.data("filterData") || {};
        var filterButton = table.siblings(".dt-buttons").find(".filter-options-button")
            .attr("data-toggle", "dropdown")
            .wrap("<div class='dropdown pull-right'></div>");
        var filterDiv = $("<div>", {class: "dropdown-menu"})
            .insertAfter(filterButton)
            .on('click', function(e){e.stopPropagation();});
        var filterDisplay = $("<div>", {class: "filter-display m-y-1 text-right"}).insertAfter(filterButton.parent());        
        
        var options = $("#" + table.data("filter-options-id")).clone();
        var propertiesSelect = options.find("select[data-type=properties]");
        var valuesSelect = options.find("select[data-type=values]");
        
        var createFilterRow = function(select, k, v){
            var option = select.find("option[value='" + k + "']");
            if (option.length <= 0) {
                return null;
            }
            if (v) {
                filterDisplay.append(
                    $("<span>", {class: "badge m-l-1"}).append(
                        $("<strong>").text((option.text() || k) + ": "),
                        $("<span>").text(v),
                        $("<span>", {
                            class: "fa fa-times-circle m-l-1", 
                            role: "button", 
                            "data-key": k
                        }).on("click", function(){
                            var data = table.data("filterData");
                            delete data[$(this).data("key")];
                            table.data("filterData", data);
                            table.data("pageToken", "");
                            table.data("previousPageTokens", []);
                            table.DataTable().state.save();
                            sdt.load(table);
                        })
                    )
                );
                filterButton.removeClass("btn-subtle").addClass("btn-default");
            }
            return $("<tr>", {"data-key": k}).append(
                $("<td>").append(option.text() || k),
                $("<td>").append($("<input>", {type: "text", value: v, class: "form-control"})),
                $("<td>", {class: "text-right"}).append(
                    $("<button>", {class: "btn btn-link danger"})
                        .append($("<span>", {class: "fa fa-times"}))
                        .on("click", function(){$(this).closest("tr").remove()})
                )
            );
        }
        var createFilterControl = function(select){
            return $("<tr>").append(
                $("<td>", {colspan: 2}).append(select.css("width", "100%")),
                $("<td>", {class: "text-right"}).css("width", "1%").append(
                    $("<button>", {class: "btn btn-default"}).append($("<span>", {class: "fa fa-plus"}))
                        .on("click", function(e){
                            var select = $(this).closest("div").find("select");
                            if (select.val()){
                                var row = $(this).closest("tbody").find("tr[data-key='" + select.val() + "']");
                                if (!row.length){
                                    var row = createFilterRow(select, select.val());
                                    $(this).closest("tr").before(row);
                                }
                                select.val("");
                                row.find("input").focus();
                            } else {
                                $(this).closest("tr").find("select").focus();
                            }
                        })
                )
            );
        }
        if (propertiesSelect.length){
            filterDiv.append(
                $("<div>", {class: "p-x-2 p-b-1"}).append(
                    $("<table>", {class: "table m-a-0 properties-table"}).append(
                        $("<thead>").append($("<tr>").append($("<th>", {colspan: 3}).append("Filter By Properties"))),
                        $("<tbody>").append(
                            $.map(filterData, function(v, k){return createFilterRow(propertiesSelect, k, v);}),
                            createFilterControl(propertiesSelect)
                        )
                    )
                )
            );
        }
        if (valuesSelect.length){
            filterDiv.append(
                $("<div>", {class: "p-x-2 p-b-1"}).append(
                    $("<table>", {class: "table m-a-0 values-table"}).append(
                        $("<thead>").append($("<tr>").append($("<th>", {colspan: 2}).append("Filter By Field Values"))),
                        $("<tbody>").append(
                            $.map(filterData, function(v, k){return createFilterRow(valuesSelect, k, v);}),
                            createFilterControl(valuesSelect)
                        )
                    )
                )
            );
        }
        filterDiv.append(
            $("<div>", {class: "p-x-2 p-y-1 text-right"}).append(
                $("<button>", {class: "btn btn-success apply-filter"}).text("Apply")
                    .on("click", function(e){
                        var container = $(this).closest("div.dropdown-menu");
                        var filterData = {};
                        container.find("table.properties-table tr[data-key]").each(function(){
                            if ($(this).data("key") && $(this).find("input").val()){
                                filterData[$(this).data("key")] = $(this).find("input").val().trim();
                            }
                        });
                        container.find("table.values-table tr[data-key]").each(function(){
                            if ($(this).data("key") && $(this).find("input").val()){
                                filterData[$(this).data("key")] = $(this).find("input").val().trim();
                            }
                        });
                        if (JSON.stringify(filterData) !== JSON.stringify(table.data("filterData"))){
                            console.log("filter changed", filterData);
                            table.data("filterData", filterData);
                            table.data("pageToken", "");
                            table.data("previousPageTokens", []);
                            table.DataTable().state.save();
                            sdt.load(table);
                        }
                        filterButton.dropdown("toggle");
                    }),
                $("<button>", {class: "btn btn-link"}).text("Reset")
                    .on("click", function(e){
                        $(this).closest("div.dropdown-menu").find("table tr[data-key]").remove();
                        $(this).siblings("button.apply-filter").trigger("click");
                    })
            )
        )
    };

    sdt.buildURL = function(table){
        var url = bundle.apiLocation() + table.data("source")
            + "?include=" + table.data("source-include")
            + (table.data("source-params") ? "&" + table.data("source-params") : "")
            + "&limit=" + (table.data("source-limit") || 25)
            + (table.data("pageToken") ? "&pageToken=" + table.data("pageToken") : "");
        if (table.data("source-query") || table.data("filter-query")) {
            url += "&q=";
            if (table.data("source-query-q") && table.data("filter-query")) {
                url += table.data("source-query") + encodeURIComponent(" AND ") + table.data("filter-query");
            }
            else {
                url += table.data("source-query") || table.data("filter-query");
            }
        }
        console.log(url);
        return url;
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
                console.log("load state", data.filterData);
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
                // Build filters
                table.data("filterData", data.filterData || {});
                var filterQuery = "";
                if (data.filterData){
                    $.each(data.filterData, function(k, v){
                        if (k && v){
                            if (filterQuery.length) {
                                filterQuery += " AND ";
                            }
                            filterQuery += k + "=\"" + v + "\"";
                        }
                    });
                }
                table.data("filter-query", encodeURIComponent(filterQuery));
                // Rebuild url since pageToken may have changed
                settings.ajax.url = sdt.buildURL(table);
            },
            // Save the pageToken and previous pageTokens along with the state of the table
            stateSaveParams: function (settings, data) {
                console.log("save state", table.data("filterData"));
                data.pageToken = table.data("pageToken") || "";
                data.previousPageTokens = table.data("previousPageTokens") || [];
                data.filterData = table.data("filterData") || {};
            },
            initComplete: function(settings, json){
                table.data("nextPageToken", json.nextPageToken || null);
                console.log("done");
            }
        };
        if (table.data("toggle-columns") || table.data("filter-options-id")){
            options.buttons = {
                dom: {
                    container: {
                        tag: "div",
                        className: "dt-buttons"
                    }
                },
                buttons: []
            };
            if (options.dom.indexOf("B") < 0){
                options.dom = "B" + options.dom;
            }
        }
        if (table.data("toggle-columns")){
            options.buttons.buttons.push({
                extend: "colvis",
                text: table.data("toggle-columns") + " <span class='fa fa-caret-down'></span>",
                collectionLayout: 'column-visibility-layout',
                className: "column-visibility-button btn-subtle",
                columns: ".visibility-toggle"
            });
        }
        if (table.data("filter-options-id")){
            options.buttons.buttons.push({
                text: "<span class='fa fa-filter'></span>",
                className: "filter-options-button pull-right btn-subtle"
            });
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