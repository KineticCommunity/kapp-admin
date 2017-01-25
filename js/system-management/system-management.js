(function($, _) {
    /*----------------------------------------------------------------------------------------------
     * DOM MANIPULATION AND EVENT REGISTRATION
     *   This section is executed on page load to register events and otherwise manipulate the DOM.
     *--------------------------------------------------------------------------------------------*/  
    $(function() {    
        /*
         * Initialize Colorpicker / Spinner
         */
        $('.colorpicker-component').colorpicker();
        $('.spinner').spinner()

        // Add Add Click Event to Save System Button
        $("button.update-system-btn").on("click", systemManagement.updateSpace);

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
    
    // Private namesapce for system management
    var systemManagement = new Object();
    _.templateSettings = { interpolate: /\{\{(.+?)\}\}/g };

    /*----------------------------------------------------------------------------------------------
     * COMMON FUNCTIONS
     *--------------------------------------------------------------------------------------------*/
    
    systemManagement.updateSpace = function(){
        
        // Build object to hold Space Object
        var space = {
            attributes: new Array()
        };
        // Build object to hold Attribute Values
        var attributes = new Object();

        // Populate Attributes Object based on attribute inputs
        // Since ALL of the attributes are listed in a hidden element
        // they will all be added to the attributes array. They will
        // Be overridden by the attributes that are visible in to the 
        // user though.
        $('.m-b-2 input, .m-b-2 select').each(function(){
            var name = this.name;
            var value = this.value;
            attributes[name] = [value];
        });

        // Add the Attributes to the Space Object 
        space.attributes = $.map(attributes, function(value, key){
            return {name: key, values: value};
        });

        // Update the Space
        $.ajax({
            method: "put",
            url: encodeURI(bundle.apiLocation() + "/space"),
            dataType: "json",
            contentType: "application/json",
            data: JSON.stringify(space),
            beforeSend: function(){
                $("button.update-system-btn").notifie({
                    anchor: "div.row",
                    severity: "info",
                    message: $("<div>").append(
                        $("<span>", {class: "fa fa-spinner fa-spin"}),
                        $("<span>").append("Updating System")
                    ),
                    margin: {'margin':'0'},
                    exitEvents: "click"
                });
            },
            success: function(data){
                window.location.href = window.location.pathname;
            },
            error: function(jqXHR, textStatus, errorThrown){
                try { 
                    errorThrown = JSON.parse(jqXHR.responseText).error; 
                } catch(e){}
                $("button.update-system-btn").notifie({
                    anchor: "div.row",
                    message: "An error occurred while updating the system: " + errorThrown,
                    margin: {'margin':'0'},
                    exitEvents: "click"
                });
            }
        });
    }

})(jQuery, _);



