/* JS Specific to the Datastore Console */
(function($, _) {
    /*----------------------------------------------------------------------------------------------
     * DOM MANIPULATION AND EVENT REGISTRATION 
     *   This section is executed on page load to register events and otherwise manipulate the DOM.
     *--------------------------------------------------------------------------------------------*/
    $(function() {
        
        /*
         * Initialize DataTable for entries data
         */
        $("table[data-table-source]").each(function(i,table){
            $.ajax({
                method: "GET",
                url: encodeURI($(table).data("table-source")),
                dataType: "json",
                contentType: "application/json",
                success: function(data){
                    var pageLength = $(table).data("page-length") || 25;
                    var dom = $(table).data("dom") 
                        || data.data.length > pageLength 
                            ? "<'dt-title'f>t<'pull-right'p>i"
                            : ($(table).find("tbody tr").length > 0
                                ? "<'dt-title'f>ti"
                                : "<'dt-title'>t");
                    records = $.extend(data, {
                        pageLength: pageLength,
                        dom: dom,
                        language: {
                            search: "Filter",
                            paginate: {
                                previous: "<",
                                next: ">"
                            }
                        },
                        drawCallback: function(){
                            $("[data-tooltip]").tooltip();
                        },
                        headerCallback: function( thead ){
                            if ($(thead).closest("table").data("delete-all")){
                                $(thead).find("th.actions").html(
                                    $("<div>", {class: "dropdown more-actions pull-right"}).append(
                                        "<span data-toggle=\"dropdown\" class=\"fa fa-chevron-down\"></span>",
                                        "<ul role=\"menu\" class=\"dropdown-menu dropdown-menu-right\">" + 
                                            "<li><a class=\"delete-all-btn\">Delete All</a></li>" + 
                                        "</ul>"
                                    )
                                );
                            }
                        },
                        rowCallback: function(row, data){
                            $(row).find("td.locale").html("<span class=\"btn-xs btn-subtle\" disabled data-tooltip title=\"" 
                                    + data.language + "\">" + data.locale + "</span>");
                            $(row).find("td.context").html("<span class=\"btn-xs btn-subtle\" data-tooltip title=\"" 
                                    + data.context + "\"><span class=\"ellipsis\">" + data.context + "</span></span>");
                            $(row).find("td.key").each(function(){
                                var keyUrl = data.i18nKappUrl + "&page=translations/key&context=" 
                                        + data.context + "&key=" + encodeURIComponent(data.key);
                                if (data.byLocale === true){
                                    keyUrl += "&locale=" + data.locale;
                                }
                                $(this).html($("<a>", {href: keyUrl}).text(data.key));
                            });
                            if (data.references && data.references.length > 0){
                                $(row).find("td.references").html($("<span>", {
                                    class: "fa fa-info fa-fw text-muted", 
                                    "data-tooltip": true, 
                                    title: "Referenced by:\n- " + data.references.join("\n- ")
                                }));
                            }
                            $(row).find("td.translation").text(data.value);
                            if (data.inherited){
                                $(row).find("td.translation").addClass("inherited-value")
                                    .prepend($("<span>", {
                                        class: "fa fa-fw fa-level-up fa-rotate-90",
                                        "data-tooltip": "",
                                        title: "Inherited from:\n" + data.sourceContext + " | " + data.sourceLocale
                                    }));
                            }
                            if (data.missing){
                                $(row).find("td.translation").html("<span class=\"btn-xs btn-warning\" disabled>Missing</span>");
                            }
                            if (data.virtual){
                                $(row).find("td.actions button.delete-translation-btn").attr("disabled", true);
                            }
                        }
                    });
                    if ($(table).data("empty-message")){
                        records.language.emptyTable = $(table).data("empty-message");
                        if ($(table).data("seed")){
                            var seedButton = $("<button>", {
                                    class: "btn btn-xs btn-default seed-context-btn pull-right",
                                    "data-seed-target-locale": $(table).data("locale"),
                                    "data-seed-context": $(table).data("context")
                                })
                                .append("<span class='fa fa-fw fa-plus'></span>")
                                .append("Import Keys From Default Locale");
                            records.language.emptyTable += seedButton.get(0).outerHTML;
                            $(table).on("click", "button.seed-context-btn", function(){
                                var self = $(this);
                                var url = bundle.adminTranslations.apiBaseUrl;
                                if ($(this).data("seed-context").indexOf("form.") === 0){
                                    url += "/forms/" + $(this).data("seed-context").substring(5) + "/seedKeys";
                                }
                                else {
                                    url += "/translationContexts/" + $(this).data("seed-context") + "/seedKeys"
                                }
                                $.ajax({
                                    method: "post",
                                    url: url,
                                    data: JSON.stringify({
                                        code: $(this).data("seed-target-locale")
                                    }),
                                    dataType: "json",
                                    contentType: "application/json",
                                    beforeSend: function(){
                                        self.notifie({
                                            anchor: "table",
                                            message: "<span class='fa fa-spinner fa-spin'></span> Importing Keys...",
                                            severity: "info",
                                            permanent: true
                                        });
                                    },
                                    success: function(){
                                        window.location.reload();
                                    },
                                    error: function(jqXHR, textStatus, errorThrown){
                                        try { 
                                            errorThrown = JSON.parse(jqXHR.responseText).error; 
                                        } catch(e){}
                                        self.notifie({
                                            anchor: "table",
                                            message: "Failed to import keys from the default locale.<br>Error: " + errorThrown
                                        });
                                    }
                                });
                            });
                        }
                    }
                    // Build DataTable
                    $(table).dataTable(records);
                    $(table).parent().find("div.dt-title").prepend($("<h4>", {class: "pull-left"}).append($(table).data("table-name")));
                    $(table).on("click", "td", function(e){
                        if (e.target == this){
                            $(this).closest("tr").toggleClass("full-text");
                        }
                    }).on("click", "button.edit-translation-btn", function(){
                        new TranslationEditor($(this).closest("tr"));
                    }).on("click", "button.delete-translation-btn", function(){
                        var row = $(this).closest("tr");
                        var table = row.closest("table");
                        var data = table.DataTable().row(row).data();
                        var url = bundle.adminTranslations.apiBaseUrl;
                        if (data.context.indexOf("form.") === 0){
                            url += "/forms/" + data.context.substring(5) + "/deleteTranslation";
                        }
                        else {
                            url += "/translationContexts/" + data.context + "/deleteTranslation"
                        }
                        // Create Modal to confirm delete
                        var confirmDelete = new KD.Modal({
                            header: "<h4>Confirm Delete</h4>",
                            body: "Are you sure you want to delete the <b>" + data.language 
                                    + "</b> translation in the <b>" + data.context 
                                    + "</b> context for the key <b>" + data.key + "</b>?",
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
                            accept: function(){
                                $.ajax({
                                    method: "post",
                                    url: url,
                                    data: JSON.stringify({
                                        key: data.key,
                                        locale: data.locale,
                                        value: data.value
                                    }),
                                    dataType: "json",
                                    contentType: "application/json",
                                    success: function(){
                                        window.location.reload();
                                    },
                                    error: function(jqXHR, textStatus, errorThrown){
                                        try { 
                                            errorThrown = JSON.parse(jqXHR.responseText).error; 
                                        } catch(e){}
                                        row.closest("table").notifie({
                                            message: "Failed to delete the <b>" + data.language 
                                                        + "</b> translation in the <b>" + data.context 
                                                        + "</b> context for the key <b>" + data.key + "</b><br>Error: " + errorThrown
                                        });
                                        $(document).scrollTop(0);
                                    }
                                });
                            }
                        });
                        // Show confirmation dialog
                        confirmDelete.show();
                        // Blur delete button
                        $(this).blur();
                    }).on("click", "a.delete-all-btn", function(){
                        var self = $(this);
                        var url = bundle.adminTranslations.apiBaseUrl;
                        var confirmMessage = "";
                        var locale = $(this).closest("table").data("locale");
                        var context = $(this).closest("table").data("context");
                        if (context.length > 0){
                            confirmMessage = "Are you sure you want to delete <b>ALL</b> of the "  
                                + "translations in the <b>" + context + "</b> context " 
                                + "for all locales?";
                            if (context.indexOf("form.") === 0){
                                url += "/forms/" + context.substring(5) + "/translations";
                            }
                            else {
                                url += "/translationContexts/" + context + "/translations"
                            }
                            if (locale.length > 0){
                                url += "?locale=" + locale;
                                confirmMessage = "Are you sure you want to delete <b>ALL</b> of the "  
                                    + "translations in the <b>" + context + "</b> context " 
                                    + "for the <b>" + locale + "</b> locale?";
                            }
                        }
                        else if (locale.length > 0){
                            url += "/locales/" + locale + "/translations";
                            confirmMessage = "Are you sure you want to delete <b>ALL</b> of the "  
                                + "translations in all contexts for the <b>" + locale + "</b> locale?";
                        }
                        else {
                            return;
                        }
                        
                        var confirmDelete = new KD.Modal({
                            header: "<h4>Confirm Delete</h4>",
                            body: confirmMessage,
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
                            accept: function(){
                                $.ajax({
                                    method: "delete",
                                    url: url,
                                    contentType: "application/json",
                                    beforeSend: function(){
                                        self.notifie({
                                            anchor: "table",
                                            message: "<span class='fa fa-spinner fa-spin'></span> Deleting All Translations...",
                                            severity: "info",
                                            permanent: true
                                        });
                                    },
                                    success: function(){
                                        window.location.reload();
                                    },
                                    error: function(jqXHR, textStatus, errorThrown){
                                        try { 
                                            errorThrown = JSON.parse(jqXHR.responseText).error; 
                                        } catch(e){}
                                        self.notifie({
                                            anchor: "table",
                                            message: "Failed to delete the translations.<br>Error: " + errorThrown
                                        });
                                    }
                                });
                            }
                        });
                        // Show confirmation dialog
                        confirmDelete.show();
                        // Blur delete button
                        $(this).blur();
                    });
                },
                error: function(jqXHR, textStatus, errorThrown){
                    try { 
                        errorThrown = JSON.parse(jqXHR.responseText).error; 
                    } catch(e){}
                    $(table).empty().notifie({
                        message: "Failed to load translation records.<br>" + errorThrown
                    });
                }
            });
        });
        
        /*
         * Initialize DataTable for adding entries
         */
        $("table[data-add-entries-table]").each(function(i,table){
            var tableContainer = $(table).closest("div.new-entries-container");
            var addContainer = tableContainer.siblings("div.add-entry-container");
            
            var options = {
                columns: [
                    {
                        title: "Locale",
                        data: "locale",
                        class: "locale",
                        width: "10%"
                    },
                    {
                        title: "Context",
                        data: "context",
                        class: "context",
                        width: "15%"
                    },
                    {
                        title: "Key",
                        data: "key",
                        class: "key ellipsis"
                    },
                    {
                        title: "Translation",
                        data: "value",
                        class: "translation ellipsis"
                    },
                    {
                        title: "",
                        orderable: false,
                        searchable: false,
                        defaultContent: "<div class=\"btn-group pull-right\" role=\"group\"><button class=\"edit-translation-btn btn btn-xs btn-default\" type=\"button\"><span class=\"fa fa-pencil\"></span></button><button class=\"delete-translation-btn btn btn-xs btn-danger\" type=\"button\"><span class=\"fa fa-times\"></span></button></div>",
                        class: "actions",
                        width: "8%"
                    }
                ],
                data: [],
                paging: false,
                dom: "<'dt-title'f>ti",
                language: {
                    search: "Filter"
                },
                drawCallback: function(){
                    $("[data-tooltip]").tooltip();
                },
                rowCallback: sourcedTableRowCallback
            };
            if ($(table).data("empty-message")){
                options.language.emptyTable = $(table).data("empty-message");
            }
            if ($(table).data("context").trim().length > 0){
                options.columns = _.reject(options.columns, {title: "Context"});
            }

            // Build DataTable
            $(table).dataTable(options);
            $(table).parent().find("div.dt-title").prepend($("<h4>", {class: "pull-left"}).append($(table).data("table-name")));
            $(table).on("click", "td", function(e){
                if (e.target == this){
                    $(this).closest("tr").toggleClass("full-text");
                }
            }).on("click", "button.edit-translation-btn", function(){
                var row = $(this).closest("tr");
                var table = row.closest("table");
                var data = table.DataTable().row(row).data();
                addContainer.find("select[data-entry-locale]").val(data.locale);
                addContainer.find("select[data-entry-context]").val(data.context);
                addContainer.find("input[data-entry-key]").val(data.key);
                addContainer.find("textarea[data-entry-value]").val(data.value).focus();
                $(document).scrollTop(0);
            }).on("click", "button.delete-translation-btn", function(){
                var row = $(this).closest("tr");
                var table = row.closest("table");
                var dtRow = table.DataTable().row(row);
                var data = table.DataTable().row(row).data();
                var url = bundle.adminTranslations.apiBaseUrl;
                if (data.context.indexOf("form.") === 0){
                    url += "/forms/" + data.context.substring(5) + "/deleteTranslation";
                }
                else {
                    url += "/translationContexts/" + data.context + "/deleteTranslation"
                }
                // Create Modal to confirm delete
                var confirmDelete = new KD.Modal({
                    header: "<h4>Confirm Delete</h4>",
                    body: "Are you sure you want to delete the <b>" + data.language 
                            + "</b> translation in the <b>" + data.context 
                            + "</b> context for the key <b>" + data.key + "</b>?",
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
                    accept: function(){
                        $.ajax({
                            method: "post",
                            url: url,
                            data: JSON.stringify({
                                key: data.key,
                                locale: data.locale,
                                value: data.value
                            }),
                            dataType: "json",
                            contentType: "application/json",
                            success: function(){
                                dtRow.remove().draw(false);
                            },
                            error: function(jqXHR, textStatus, errorThrown){
                                try { 
                                    errorThrown = JSON.parse(jqXHR.responseText).error; 
                                } catch(e){}
                                row.closest("table").notifie({
                                    message: "Failed to delete the <b>" + data.language 
                                                + "</b> translation in the <b>" + data.context 
                                                + "</b> context for the key <b>" + data.key + "</b><br>Error: " + errorThrown
                                });
                                $(document).scrollTop(0);
                            }
                        });
                    }
                });
                // Show confirmation dialog
                confirmDelete.show();
                // Blur delete button
                $(this).blur();
            });
        });
        
        function sourcedTableRowCallback(row, data){
            $(row).find("td.locale").html("<span class=\"btn-xs btn-subtle\" disabled data-tooltip title=\"" 
                    + data.language + "\">" + data.locale + "</span>");
            $(row).find("td.context").html("<span class=\"btn-xs btn-subtle\" data-tooltip title=\"" 
                    + data.context + "\"><span class=\"ellipsis\">" + data.context + "</span></span>");
            $(row).find("td.key").each(function(){
                var keyUrl = data.i18nKappUrl + "&page=translations/key&context=" 
                        + data.context + "&key=" + encodeURIComponent(data.key);
                if (data.byLocale === true){
                    keyUrl += "&locale=" + data.locale;
                }
                $(this).html($("<a>", {href: keyUrl}).text(data.key));
            });
            if (data.references && data.references.length > 0){
                $(row).find("td.references").html($("<span>", {
                    class: "fa fa-info fa-fw text-muted", 
                    "data-tooltip": true, 
                    title: "Referenced by:\n- " + data.references.join("\n- ")
                }));
            }
            $(row).find("td.translation").text(data.value);
            if (data.inherited){
                $(row).find("td.translation").addClass("inherited-value")
                    .prepend($("<span>", {
                        class: "fa fa-fw fa-level-up fa-rotate-90",
                        "data-tooltip": "",
                        title: "Inherited from:\n" + data.sourceContext + " | " + data.sourceLocale
                    }));
            }
            if (data.missing){
                $(row).find("td.translation").html("<span class=\"btn-xs btn-warning\" disabled>Missing</span>");
            }
            if (data.virtual){
                $(row).find("td.actions button.delete-translation-btn").attr("disabled", true);
            }
        }
        
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
        
        /*
         * Event handler for changing the language on a page of entries
         */
        $("select.change-locale").on("change", function(){
            $("table[data-state-save='true']").DataTable().state.clear();
            window.location.replace($(this).val());
        });
        
        /*
         * Event handler for selecting a new locale to enable
         */
        $("select.enable-locale").on("change", function(){
            var row = $(this).closest("tr");
            if ($(this).val()){
                row.find("button.enable-locale-btn").attr("disabled", false);
                row.find("td.locale-code-cell").html("<span class=\"btn-sm btn-subtle\" disabled>" + $(this).val() + "</span>");
            }
            else {
                row.find("button.enable-locale-btn").attr("disabled", true);
                row.find("td.locale-code-cell").empty();
            }
        });
        
        /*
         * Click event handler for enabling a new locale
         */
        $("button.enable-locale-btn").on("click", function(){
            var row = $(this).closest("tr");
            var button = $(this);
            var select = row.find("select.enable-locale");
            var locale = select.val();
            var localeName = select.find("option:selected").text();
            $.ajax({
                method: "put",
                url: bundle.adminTranslations.apiBaseUrl + "/locales",
                data: JSON.stringify({
                    code: locale
                }),
                beforeSend: function(){
                    button.attr("disabled", true);
                },
                success: function(){
                    window.location.reload();
                },
                error: function(jqXHR, textStatus, errorThrown){
                    try { 
                        errorThrown = JSON.parse(jqXHR.responseText).error; 
                    } catch(e){}
                    row.closest("table").notifie({
                        message: "Failed to enable the <b>" + localeName + "</b> locale <b>" + locale + "</b>.<br>Error: " + errorThrown
                    });
                    button.attr("disabled", false);
                }
            });
        });
        
        /*
         * Click event handler for enabling an unexpected locale
         */
        $("button.enable-unexpected-locale-btn").on("click", function(e){
            var button = $(this);
            var localeCode = $(this).data("locale-code");
            $.ajax({
                method: "put",
                url: bundle.adminTranslations.apiBaseUrl + "/locales",
                data: JSON.stringify({
                    code: localeCode
                }),
                beforeSend: function(){
                    button.attr("disabled", true);
                },
                success: function(){
                    window.location.replace(bundle.adminTranslations.i18nKappUrl + "&page=translations/locale&locale=" + localeCode);
                },
                error: function(jqXHR, textStatus, errorThrown){
                    try { 
                        errorThrown = JSON.parse(jqXHR.responseText).error; 
                    } catch(e){}
                    button.closest("table").notifie({
                        message: "Failed to enable the unexpected locale <b>" + localeCode + "</b>.<br>Error: " + errorThrown
                    });
                    button.attr("disabled", false);
                }
            });
        });
        
        /*
         * Click event handler for disabling a locale
         */
        $("a.disable-locale-btn").on("click", function(){
            var row = $(this).closest("tr");
            var locale = row.data("locale");
            var localeName = row.data("locale-name");
            // Create Modal to confirm disable
            var confirmDisable = new KD.Modal({
                header: "<h4>Confirm Disable</h4>",
                body: "Are you sure you want to disable the <b>" + localeName + "</b> locale <b>" + locale + "</b>?",
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
                accept: function(){
                    $.ajax({
                        method: "delete",
                        url: bundle.adminTranslations.apiBaseUrl + "/locales/" + locale,
                        success: function(){
                            window.location.reload();
                        },
                        error: function(jqXHR, textStatus, errorThrown){
                            try { 
                                errorThrown = JSON.parse(jqXHR.responseText).error; 
                            } catch(e){}
                            row.closest("table").notifie({
                                message: "Failed to disable the <b>" + localeName + "</b> locale <b>" + locale + "</b>.<br>Error: " + errorThrown
                            });
                        }
                    });
                }
            });
            // Show confirmation dialog
            confirmDisable.show();
            // Blur delete button
            $(this).blur();
        });
        
        /*
         * Click event handler for setting a default locale
         */
        $("a.default-locale-btn").on("click", function(){
            var row = $(this).closest("tr");
            var locale = row.data("locale");
            var localeName = row.data("locale-name");
            // Create Modal to confirm disable
            var confirmDisable = new KD.Modal({
                header: "<h4>Confirm Default</h4>",
                body: "Are you sure you want to set the <b>" + localeName + "</b> locale <b>" + locale + "</b> as the default locale?",
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
                accept: function(){
                    $.ajax({
                        method: "put",
                        url: bundle.adminTranslations.apiBaseUrl + "/defaultLocale",
                        data: JSON.stringify({
                            code: locale
                        }),
                        success: function(){
                            window.location.reload();
                        },
                        error: function(jqXHR, textStatus, errorThrown){
                            try { 
                                errorThrown = JSON.parse(jqXHR.responseText).error; 
                            } catch(e){}
                            row.closest("table").notifie({
                                message: "Failed to set the <b>" + localeName + "</b> locale <b>" + locale + "</b> as the default locale.<br>Error: " + errorThrown
                            });
                        }
                    });
                }
            });
            // Show confirmation dialog
            confirmDisable.show();
            // Blur delete button
            $(this).blur();
        });
                
        /*
         * Event handlers for preventing not allowed characters in custom context name 
         * and for enabling/disabling the add button when value is entered.
         */
        $("input.custom-context-name").on("keypress", function(e){
            var regex = new RegExp("^[a-z0-9\.-]+$");
            var key = String.fromCharCode(!e.charCode ? e.which : e.charCode);
            if (!regex.test(key)) {
               e.preventDefault();
               return false;
            }
        }).on("keyup", function(){
            var button = $(this).closest("tr").find("button.add-custom-context-btn");
            if ($(this).val().length > 0) {
                button.attr("disabled", false);
            }
            else {
                button.attr("disabled", true);
            }
        });
        
        /*
         * Event handler for adding a custom context
         */
        $("button.add-custom-context-btn").on("click", function(){
            var row = $(this).closest("tr");
            var button = $(this);
            var span = row.find("span.custom-context-prefix");
            var input = row.find("input.custom-context-name");
            var contextName = span.text() + input.val();
            $.ajax({
                method: "post",
                url: bundle.adminTranslations.apiBaseUrl + "/translationContexts",
                data: JSON.stringify({
                    name: contextName
                }),
                dataType: "json",
                contentType: "application/json",
                beforeSend: function(){
                    button.attr("disabled", true);
                },
                success: function(){
                    window.location.reload();
                },
                error: function(jqXHR, textStatus, errorThrown){
                    try { 
                        errorThrown = JSON.parse(jqXHR.responseText).error; 
                    } catch(e){}
                    row.closest("table").notifie({
                        message: "Failed to create new context <b>" + contextName + "</b><br>Error: " + errorThrown
                    });
                    button.attr("disabled", false);
                }
            });
        });
        
        /*
         * Event handler for renaming contexts
         */
        $(".rename-context-button").on("click", function(e){
            var self = $(this);
            var currentName = $(this).data("context-name");
            var isFormContext = currentName.indexOf("form.") === 0;
            
            // Create Modal to for renaming context
            var renameDialog = new KD.Modal({
                header: "<h4>Rename Context</h4>",
                body: function(element) {
                    element.addClass("rename-context-body").append(
                        $("<p>").append(
                            "Please enter a new context name to rename the <b>" + currentName + "</b> context."
                        ),
                        $("<div>", {class: "input-group"}).append(
                            $("<span>", {class: "input-group-addon"}).append(
                                $("<span>", {}).append(
                                    $("<input>", {type: "radio", name: "context-prefix", value: "custom.", id: "custom-prefix", checked: !isFormContext}),
                                    $("<label>", {for: "custom-prefix"}).append("custom.")
                                )
                            ),
                            $("<span>", {class: "input-group-addon"}).append(
                                $("<span>", {}).append(
                                    $("<input>", {type: "radio", name: "context-prefix", value: "form.", id: "form-prefix", checked: isFormContext}),
                                    $("<label>", {for: "form-prefix"}).append("form.")
                                )
                            ),
                            $("<input>", {class: "form-control new-context-name", placeholder: "Context Name"}).on("keypress", function(e){
                                    var regex = new RegExp("^[a-z0-9\.-]+$");
                                    var key = String.fromCharCode(!e.charCode ? e.which : e.charCode);
                                    if (!regex.test(key)) {
                                       e.preventDefault();
                                       return false;
                                    }
                                }).on("keyup", function(){
                                    var button = $(this).closest(".rename-context-body")
                                            .siblings(".rename-context-actions")
                                            .find("button.rename-context-save-btn");
                                    if ($(this).val().length > 0) {
                                        button.attr("disabled", false);
                                    }
                                    else {
                                        button.attr("disabled", true);
                                    }
                                })
                        )
                    );
                },
                footer: function(element, actions) {
                    element.addClass("text-right rename-context-actions").append(
                        $("<button>", {class: "btn btn-success rename-context-save-btn", disabled: true}).text("Rename").on("click", actions.accept),
                        $("<button>", {class: "btn btn-link"}).text("Cancel").on("click", actions.dismiss)
                    );
                },
                size: "md",
                backdrop: true,
                backdropclose: true,
                keyboardclose: true,
                renderCallback: false,
                accept: function(){
                    var dialogContent = $(this).closest(".rename-context-actions")
                            .siblings(".rename-context-body");
                    var prefix = dialogContent.find("input[name='context-prefix']:checked").val();
                    var suffix = dialogContent.find("input.new-context-name").val();
                    var newName = prefix + suffix;
                    $.ajax({
                        method: "put",
                        url: bundle.adminTranslations.apiBaseUrl + "/translationContexts/" + currentName,
                        data: JSON.stringify({
                            name: newName
                        }),
                        dataType: "json",
                        contentType: "application/json",
                        success: function(){
                            window.location.replace(bundle.adminTranslations.i18nKappUrl + "&page=translations/context&context=" + newName);
                        },
                        error: function(jqXHR, textStatus, errorThrown){
                            try { 
                                errorThrown = JSON.parse(jqXHR.responseText).error; 
                            } catch(e){}
                            self.closest("table, h3").notifie({
                                message: "Failed to rename the context <b>" + currentName + "</b><br>Error: " + errorThrown
                            });
                        }
                    });
                }
            });
            // Show confirmation dialog
            renameDialog.show();
            // Blur delete button
            $(this).blur();
        });
        
        /*
         * Handler for adding new entries
         */
        $("div.add-entry-container").each(function(){
            var container = $(this);
            var table = container.siblings("div.new-entries-container").find("table");
            var saveButton = container.find("button[data-entry-save]");
            
            saveButton.on("click", function(e){
                var locale = container.find("select[data-entry-locale]").val();
                var language = container.find("select[data-entry-locale] option:selected").text();
                language = language.substring(0, language.indexOf("|")-1);
                var context = container.find("select[data-entry-context]").val();
                var key = container.find("input[data-entry-key]").val();
                var value = container.find("textarea[data-entry-value]").val();
                var error = "";
                if (locale.length <= 0){
                    error += "Locale is required.<br>";
                }
                if (context.length <= 0){
                    error += "Context is required.<br>";
                }
                if (key.length <= 0){
                    error += "Key is required.<br>";
                }
                if (error.length > 0){
                    saveButton.notifie({
                        anchor: "div.add-entry-container",
                        message: error,
                        exitEvents: "click"
                    });
                }
                else {
                    var url = bundle.adminTranslations.apiBaseUrl;
                    if (context.indexOf("form.") === 0){
                        url += "/forms/" + context.substring(5) + "/upsertTranslation";
                    }
                    else {
                        url += "/translationContexts/" + context + "/upsertTranslation"
                    }
                    $.ajax({
                        method: "put",
                        url: url,
                        data: JSON.stringify({
                            key: key,
                            locale: locale,
                            value: value
                        }),
                        dataType: "json",
                        contentType: "application/json",
                        beforeSend: function(){
                            saveButton.attr("disabled", true);
                        },
                        success: function(){
                            var tableData = {
                                context: context,
                                locale: locale,
                                key: key,
                                value: value,
                                i18nKappUrl: bundle.adminTranslations.i18nKappUrl,
                                references: new Array(),
                                language: language,
                                missing: false,
                                inherited: false,
                                virtual: false
                            };
                            var matchingRow = table.DataTable().row(function(i, data){
                                return data.context === tableData.context 
                                        && data.locale === tableData.locale
                                        && data.key === tableData.key;
                            });
                            if (matchingRow.length > 0){
                                matchingRow.data(tableData).draw(false);
                            }
                            else {
                                table.DataTable().row.add(tableData).draw(false);
                            }
                            container.find("textarea[data-entry-value]").val("");
                            container.find("input[data-entry-key]").val("").focus();
                            saveButton.attr("disabled", false);
                            
                            // Get publish notice
                            var publishNotice = $("a.pending-publish");
                            // If notice is hidden (no pending chnages), show it
                            if (publishNotice.is(".hide")){
                                publishNotice.removeClass("hide");
                            }
                            // If notice already shown, add plus to existing number if it hasn't been done yet
                            else {
                                publishNotice.find("span.plus-placeholder").replaceWith("+");
                            }
                        },
                        error: function(jqXHR, textStatus, errorThrown){
                            try { 
                                errorThrown = JSON.parse(jqXHR.responseText).error; 
                            } catch(e){}
                            saveButton.notifie({
                                anchor: "div.add-entry-container",
                                message: "Failed to save new translation.<br>Error: " + errorThrown,
                                exitEvents: "click"
                            });
                            saveButton.attr("disabled", false);
                        }
                    });
                }
            });
        });
        
        /*
         * Event handler for updating keys
         */
        $("button.edit-translation-key-btn").on("click", function(e){
            var self = $(this);
            var currentKey = $(this).data("key");
            var context = $(this).data("context");
            var isFormContext = context.indexOf("form.") === 0;
            
            // Create Modal for renaming key
            var renameDialog = new KD.Modal({
                header: "<h4>Update Key</h4>",
                body: function(element) {
                    element.addClass("update-key-body").append(
                        $("<p>").append(
                            "Updating the <b>" + currentKey + "</b> key will update all translations of this key."
                        ),
                        $("<input>", {
                            class: "form-control updated-key", 
                            placeholder: "Translation Key",
                            maxlength: "256",
                            value: currentKey
                        }).on("keyup", function(){
                            var button = $(this).closest(".update-key-body")
                                    .siblings(".update-key-actions")
                                    .find("button.update-key-save-btn");
                            if ($(this).val().length > 0 && $(this).val() !== currentKey) {
                                button.attr("disabled", false);
                            }
                            else {
                                button.attr("disabled", true);
                            }
                        })
                    );
                },
                footer: function(element, actions) {
                    element.addClass("text-right update-key-actions").append(
                        $("<button>", {class: "btn btn-success update-key-save-btn", disabled: true}).text("Update").on("click", actions.accept),
                        $("<button>", {class: "btn btn-link"}).text("Cancel").on("click", actions.dismiss)
                    );
                },
                size: "md",
                backdrop: true,
                backdropclose: true,
                keyboardclose: true,
                renderCallback: false,
                accept: function(){
                    var dialogContent = $(this).closest(".update-key-actions")
                            .siblings(".update-key-body");
                    var newKey = dialogContent.find("input.updated-key").val();
                    var url = bundle.adminTranslations.apiBaseUrl + 
                            (isFormContext 
                                ? "/forms/" + context.substring(5) + "/renameTranslationKey"
                                : "/translationContexts/" + context + "/renameTranslationKey");
                    $.ajax({
                        method: "post",
                        url: url,
                        data: JSON.stringify({
                            key: currentKey,
                            name: newKey
                        }),
                        dataType: "json",
                        contentType: "application/json",
                        success: function(data){
                            window.location.replace(bundle.adminTranslations.i18nKappUrl + "&page=translations/key&context=" + context + "&key=" + newKey);
                        },
                        error: function(jqXHR, textStatus, errorThrown){
                            try { 
                                errorThrown = JSON.parse(jqXHR.responseText).error; 
                            } catch(e){}
                            self.closest("table").notifie({
                                message: "Failed to update the <b>" + currentKey + "</b> key.<br>Error: " + errorThrown
                            });
                        }
                    });
                }
            });
            // Show confirmation dialog
            renameDialog.show();
            // Blur delete button
            $(this).blur();
        });
        
        /*
         * Event handler for deleting keys
         */
        $("button.delete-translation-key-btn").on("click", function(){
            var self = $(this);
            var key = $(this).data("key");
            var context = $(this).data("context");
            var isFormContext = context.indexOf("form.") === 0;
            // Create Modal to confirm delete
            var confirmDelete = new KD.Modal({
                header: "<h4>Confirm Delete</h4>",
                body: "Are you sure you want to delete the <b>" + key 
                        + "</b> translation key in the <b>" + context 
                        + "</b> context? Deleting the key will also delete all translations of the key.",
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
                accept: function(){
                    var url = bundle.adminTranslations.apiBaseUrl + 
                            (isFormContext 
                                ? "/forms/" + context.substring(5) + "/deleteTranslationKey"
                                : "/translationContexts/" + context + "/deleteTranslationKey");
                    $.ajax({
                        method: "post",
                        url: url,
                        data: JSON.stringify({
                            key: key
                        }),
                        dataType: "json",
                        contentType: "application/json",
                        success: function(){
                            window.location.replace(bundle.adminTranslations.i18nKappUrl + "&page=translations/key&context=" + context);
                        },
                        error: function(jqXHR, textStatus, errorThrown){
                            try { 
                                errorThrown = JSON.parse(jqXHR.responseText).error; 
                            } catch(e){}
                            self.closest("table").notifie({
                                message: "Failed to delete the <b>" + key 
                                    + "</b> translation key in the <b>" + context 
                                    + "</b> context.<br>Error: " + errorThrown
                            });
                        }
                    });
                }
            });
            // Show confirmation dialog
            confirmDelete.show();
            // Blur delete button
            $(this).blur();
        });
        
        /*
         * Handler for importing translations
         */
        $("button.import-translations-btn").fileupload({
            type: "post",
            url: bundle.adminTranslations.apiBaseUrl + "/translations.csv"
        }).bind('fileuploadsend', function (e, data) {
            $(this).notifie({
                anchor: "h3",
                message: "<span class='fa fa-spinner fa-spin'></span> Importing...",
                severity: "info",
                permanent: true
            });
        }).bind('fileuploaddone', function (e, data) {
            $(this).notifie({
                anchor: "h3",
                message: "<b>Import Completed Successfully</b><br>" + data.response().result.message
                    + "<br><a class='pull-right btn btn-sm btn-default' href='" + bundle.adminTranslations.i18nKappUrl + "&page=translations/publish'>"
                    + "<span class='fa fa-cloud-upload'></span> Publish Imported Changes</a>",
                severity: "info",
                permanent: true
            });
        }).bind('fileuploadfail', function (e, data) {
            var errorThrown = data.response().errorThrown;
            try { 
                errorThrown = JSON.parse(data.response().jqXHR.responseText).error; 
            } catch(e){}
            $(this).notifie({
                anchor: "h3",
                message: "Failed to import translations from the uploaded file.<br>Error: " + errorThrown,
                exitEvents: "click"
            });
        });
        
        $("button.publish-btn").on("click", function(){
            var self = $(this);
            $.ajax({
                method: "delete",
                url: bundle.adminTranslations.apiBaseUrl + "/translationsCache",
                contentType: "application/json",
                beforeSend: function(){
                    self.attr("disabled", true);
                    self.notifie({
                        anchor: "h3",
                        message: "<span class='fa fa-spinner fa-spin'></span> Publishing...",
                        severity: "info",
                        permanent: true
                    });
                },
                success: function(){
                    window.location.replace(bundle.adminTranslations.i18nKappUrl + "&page=translations/kapp");
                },
                error: function(jqXHR, textStatus, errorThrown){
                    try { 
                        errorThrown = JSON.parse(jqXHR.responseText).error; 
                    } catch(e){}
                    self.notifie({
                        anchor: "h3",
                        message: "Failed to publish changes.<br>Error: " + errorThrown,
                        exitEvents: "click"
                    });
                    self.attr("disabled", false);
                }
            });
        });
        
        $("[data-clear-entry-table-states]").each(function(i, state){
            var re = new RegExp("^DataTables_(context|missing|key|locale)_" + $(state).data("clear-entry-table-states"));
            $.each(Object.keys(window.localStorage), function(i, key){
                if (re.test(key)) {
                    localStorage.removeItem(key);
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
    // Create namespace for Admin Translations Console
    bundle.adminTranslations = bundle.adminTranslations || {};
    // Create a scoped alias to simplify references to your namespace
    var i18n = bundle.adminTranslations;

    /*----------------------------------------------------------------------------------------------
     * COMMON FUNCTIONS
     *--------------------------------------------------------------------------------------------*/
        
    /*
     * Object for enabling/disabling in page edit of entries
     */
    var TranslationEditor = function(row){
        var self = this;
        this.row = row;
        this.table = this.row.closest("table");
        this.container = this.table.closest(".entries-container");
        this.editor = this.container.siblings(".translation-editor");
        this.data = this.table.DataTable().row(this.row).data();
        
        // Clears out all data from the edit section and hides the section
        this.destroy = function(){
            self.editor.hide();
            self.container.show();
            
            self.editor.find("[data-entry-context]").empty();
            self.editor.find("[data-entry-locale]").empty();
            self.editor.find("[data-entry-language]").empty();
            self.editor.find("[data-entry-dependency]").hide();
            self.editor.find("[data-entry-dependency-count]").empty();
            self.editor.find("[data-entry-key]").empty();
            if (self.data.inherited === false){
                self.editor.find("[data-entry-translation]").val("");
            }
            else {
                self.editor.find("[data-entry-translation]").removeAttr("placeholder");
                self.editor.find("[data-entry-inherited]").hide();
                self.editor.find("[data-entry-source-context]").empty();
                self.editor.find("[data-entry-source-locale]").empty();
            }
            if (self.data.missing === true){
                self.editor.find("[data-entry-missing]").hide();
            }
            self.editor.find("button").off().removeAttr("disabled");
            self.editor.notifie({
                exit: true,
                recurseExit: true
            });
        }
        
        // Shows the edit section an populates all of it's fields
        this.build = function(){
            self.editor.find("[data-entry-context]").text(self.data.context);
            self.editor.find("[data-entry-locale]").text(self.data.locale);
            self.editor.find("[data-entry-language]").text(self.data.language);
            if (self.data.dependencyCount > 0){
                self.editor.find("[data-entry-dependency]").show();
                self.editor.find("[data-entry-dependency-count]").text(self.data.dependencyCount);
            }
            self.editor.find("[data-entry-key]").text(self.data.key);
            if (self.data.inherited === false){
                self.editor.find("[data-entry-translation]").val(self.data.value);
            }
            else {
                self.editor.find("[data-entry-translation]").attr("placeholder", self.data.value);
                self.editor.find("[data-entry-inherited]").show();
                self.editor.find("[data-entry-source-context]").text(self.data.sourceContext);
                self.editor.find("[data-entry-source-locale]").text(self.data.sourceLocale);
            }
            if (self.data.missing === true){
                self.editor.find("[data-entry-missing]").show();
            }

            self.container.hide();
            self.editor.show();
            
            self.editor.find("button[data-entry-cancel]").on("click", function(){
                self.destroy();
            });
            
            this.editor.find("button[data-entry-save]").on("click", function(){
                var selfButton = $(this);
                var url = bundle.adminTranslations.apiBaseUrl;
                if (self.data.context.indexOf("form.") === 0){
                    url += "/forms/" + self.data.context.substring(5) + "/upsertTranslation";
                }
                else {
                    url += "/translationContexts/" + self.data.context + "/upsertTranslation"
                }
                $.ajax({
                    method: "put",
                    url: url,
                    data: JSON.stringify({
                        key: self.data.key,
                        locale: self.data.locale,
                        value: self.editor.find("[data-entry-translation]").val()
                    }),
                    dataType: "json",
                    contentType: "application/json",
                    beforeSend: function(){
                        selfButton.attr("disabled", true);
                    },
                    success: function(data){
                        window.location.reload();
                    },
                    error: function(jqXHR, textStatus, errorThrown){
                        try { 
                            errorThrown = JSON.parse(jqXHR.responseText).error; 
                        } catch(e){}
                        selfButton.notifie({
                            anchor: "div",
                            message: "Failed to save translation.<br>Error: " + errorThrown,
                            margin: {margin: "8px"},
                            exitEvents: "click"
                        });
                        selfButton.attr("disabled", false);
                    }
                });
            });
        }
        
        this.build();
    }    
         
})($, _);