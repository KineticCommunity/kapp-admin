/* Common JS for Admin Kapp */
(function($, _) {
    /*----------------------------------------------------------------------------------------------
     * DOM MANIPULATION AND EVENT REGISTRATION 
     *   This section is executed on page load to register events and otherwise manipulate the DOM.
     *--------------------------------------------------------------------------------------------*/
    $(function() {
        
        /**
         * Add aside toggle and remember toggle state.
         */
        var asideSection = $("div.aside");
        if (asideSection.length){
            var asideToggle = $("<div>", {class: "aside-toggle"})
                .on("click", function(){
                    asideSection.closest("div.row").toggleClass("aside-closed");
                    sessionStorage.setItem("hideAside_" + window.location.pathname, 
                                           asideSection.closest("div.row").hasClass("aside-closed") ? "hide" : null);
                })
                .prependTo(asideSection);
            if (sessionStorage.getItem("hideAside_" + window.location.pathname) === "hide"){
                asideSection.closest("div.row").addClass("aside-closed");
            }
        }
        
        /**
         * Clear all saved DataTable states if on the home page.
         */
        $("div#admin-console-home").each(function(){
            Object.keys(window.localStorage).forEach(function(key){
                var re = new RegExp("^DataTables_.*?" + window.location.pathname + ".*");
                if (re.test(key)) {
                    window.localStorage.removeItem(key);
                }
            });
        });
        
        admin.tooltip();
        admin.momentify();
        setInterval(admin.momentify, 60000);
    });

    /*----------------------------------------------------------------------------------------------
     * COMMON INIALIZATION 
     *   This code is executed when the Javascript file is loaded
     *--------------------------------------------------------------------------------------------*/
    // Ensure the BUNDLE global object exists
    bundle = typeof bundle !== "undefined" ? bundle : {};
    // Create namespace for Admin Kapp
    bundle.admin = bundle.admin || {};
    // Create a scoped alias to simplify references to your namespace
    var admin = bundle.admin;

    /*----------------------------------------------------------------------------------------------
     * COMMON FUNCTIONS
     *--------------------------------------------------------------------------------------------*/
    
    /**
     * Returns an Object with keys/values for each of the url parameters.
     * 
     * @returns {Object}
     */
    admin.getUrlParameters = function(param) {
        var searchString = window.location.search.substring(1), params = searchString.split("&"), hash = {};
        for (var i = 0; i < params.length; i++) {
            var val = params[i].split("=");
            hash[unescape(val[0])] = unescape(val[1]);
        }
        return param ? hash[param] : hash;
    };
    
    /**
     * Generates a UUID
     */
    admin.generateUUID = function(){
        var d = new Date().getTime();
        if(window.performance && typeof window.performance.now === "function"){
            d += performance.now(); //use high-precision timer if available
        }
        var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            var r = (d + Math.random()*16)%16 | 0;
            d = Math.floor(d/16);
            return (c=='x' ? r : (r&0x3|0x8)).toString(16);
        });
        return uuid;
    };
    
    /**
     * Format date elements with appropriate attribute flags
     * Stores original date in data "date" to prevent issue if this function is run multiple times
     */
    admin.momentify = function(container) {
        var dataMomentElements = container ? container.find("[data-moment]") : $("[data-moment]");
        dataMomentElements.each(function(index, element) {
            var e = $(element);
            e.data("date", e.data("date") || e.attr("data-moment") || e.text())
             .html(moment(e.data("date")).format("LLL"));
        });
        var dataMomentAgoElements = container ? container.find("[data-moment-ago]") : $("[data-moment-ago]");
        $("[data-moment-ago]").each(function(index, element) {
            var e = $(element);
            e.data("date", e.data("date") || e.attr("data-moment-ago") || e.text())
             .html(moment(e.data("date")).fromNow());
            if (e.is("[data-toggle=tooltip]")){
              e.attr("data-original-title", moment(e.data("date")).format("LLL"));
            }
        });
        var dataMomentTitleElements = container ? container.find("[data-moment-title]") : $("[data-moment-title]");
        dataMomentTitleElements.each(function(index, element){
            var e = $(element);
            e.data("date", e.data("date") || e.attr("title") || e.attr("data-original-title"))
             .attr(e.attr("title") ? "title" : "data-original-title", moment(e.data("date")).format("LLL"));
        });
        var dataMomentDiffElements = container ? container.find("[data-moment-diff-start]") : $("[data-moment-diff-start]");
        dataMomentDiffElements.each(function(index, element) {
            var e = $(element);
            e.data("date-start", e.data("date-start") || e.attr("data-moment-diff-start") || e.text())
             .data("date-end", e.data("date-end") || e.attr("data-moment-diff-end"));
            var start = moment(e.data("date-start"));
            var end = e.data("date-end") ? moment(e.data("date-end")) : moment();
            var diff = end.valueOf() - start.valueOf();
            e.html(moment.duration(diff).humanize());
        });
    }
    
    admin.tooltip = function(container) {
        var dataTooltipElements = container ? container.find("[data-toggle=tooltip]") : $("[data-toggle=tooltip]");
        dataTooltipElements.tooltip();
    }
    
    admin.openAsidePopup = function(){
        (new KD.Modal({
            header: function(element, actions) {
                element.append(
                    $("<span>", {class: "fa fa-times pull-right"}).on("click", actions.dismiss),
                    $("<span>").text("About This Page")
                );
            },
            body: function(element, actions) {
                element.append(
                    $("<div>").append($(".aside").clone(true, true).children())
                ).find(".aside-toggle").remove();
            },
            backdrop: true,
            backdropclose: true,
            keyboardclose: true,
            renderCallback: false
        })).show();
    };
    
    /**
     * Add jQuery functions for encoding and decoding HTML
     */
    jQuery.extend({
        htmlEncode: function(value){
            return $("<div>").text(value).html();
        },
        htmlDecode: function(value){
            return $("<div>").html(value).text();
        }
    });
    
    /*----------------------------------------------------------------------------------------------
     * BUNDLE.CONFIG OVERWRITES
     *--------------------------------------------------------------------------------------------*/
    
    /**
     * Overwrite the default field constraint violation error handler to use Notifie to display the errors above the individual fields.
     */
    bundle.config = bundle.config || {};
    bundle.config.renderers = bundle.config.renderers || {};
    bundle.config.renderers.fieldConstraintViolations = function(form, fieldConstraintViolations) {
        _.each(fieldConstraintViolations, function(value, key){
            var fieldWrapper = $(form.getFieldByName(key).wrapper());
            var notifieOptions = {
                message: value.join("<br>"),
                exitEvents: "click"
            };
            if (fieldWrapper.data("notifie-anchor")){
                notifieOptions.anchor = fieldWrapper.data("notifie-anchor"); 
            }
            fieldWrapper.notifie(notifieOptions);
        });
    }
    
    /*----------------------------------------------------------------------------------------------
     * DEFINE RENDERERS FOR DATATABLES FOR VARIOUS FIELD RENDER TYPES
     *--------------------------------------------------------------------------------------------*/
    
    /**
     * Renderer for formatting dates, times, and datetimes.
     */
    $.fn.dataTable.render.moment = function(from, to, locale){
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
    
    /**
     * Renderer for formatting checkboxes.
     */
    $.fn.dataTable.render.checkbox = function(){
        return function ( d, type, row ){
            if (type === "export"){
                return $.htmlEncode(d);
            }
            var data = null;
            if (d){
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
    
    /**
     * Renderer for formatting attachments.
     */
    $.fn.dataTable.render.attachment = function(fieldName){
        return function ( d, type, row ){
            if (type === "export"){
                return d;
            }
            var data = null;
            if (d){
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
                                + row.ID
                                + "/files/"
                                + encodeURIComponent(fieldName)
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
    
    /**
     * Renderer for formatting text (encode any HTML).
     */
    $.fn.dataTable.render.text = function(){
        return function ( d, type, row ){
            return $.htmlEncode(d);
        };
    };

    /**
     * Replace variables in Notifcations with Yellow Background Color
     */
    $.fn.dataTable.render.notificationReplacement = function(){
        return function ( d, type, row ){
            if (type === "export"){
                return $.htmlEncode(d);
            }
            else {
                return d.replace(/\${(.*?)\}/g, " <span style='background-color:yellow'>\$&</span>" )
            }
        };
    };
    
    /**
     * Function to add renderers to a list of columns with renderType propertiesfor DataTables
     */
    admin.addDataTableRenderers = function(columns, renderers){
        renderers = renderers || {};
        $.each(columns, function(i, col){
            switch(col.renderType){
                case "date":
                    col.render = renderers.date || $.fn.dataTable.render.moment("date", "ll", bundle.config.userLocale);
                    break;
                case "datetime":
                    col.render = renderers.datetime || $.fn.dataTable.render.moment("datetime", "lll", bundle.config.userLocale);
                    break;
                case "time":
                    col.render = renderers.time || $.fn.dataTable.render.moment("time", "LT", bundle.config.userLocale);
                    break;
                case "checkbox":
                    col.render = renderers.checkbox || $.fn.dataTable.render.checkbox();
                    break;
                case "attachment":
                    col.render = renderers.attachment || $.fn.dataTable.render.attachment(col.data);
                    break;
                case "text":
                    col.render = renderers.text || $.fn.dataTable.render.text();
                    break;
                case "dropdown":
                    col.render = renderers.dropdown || $.fn.dataTable.render.text();
                    break;
                case "radio":
                    col.render = renderers.radio || $.fn.dataTable.render.text();
                    break;
                case "notificationReplacement":
                    col.render = renderers.notificationReplacement || $.fn.dataTable.render.notificationReplacement();
                    break;
                default: 
                    if (renderers[col.renderType]){
                        col.render = renderers[col.renderType];
                    }
            }
        });
    };
         
})($, _);