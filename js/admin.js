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
                console.log(key, re.test(key));
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
            $(form.getFieldByName(key).wrapper()).notifie({
                message: value.join("<br>"),
                exitEvents: "click"
            });
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
         
})($, _);