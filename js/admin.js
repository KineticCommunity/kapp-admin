/* Common JS for Admin Kapp */
(function($, _) {
    /*----------------------------------------------------------------------------------------------
     * DOM MANIPULATION AND EVENT REGISTRATION 
     *   This section is executed on page load to register events and otherwise manipulate the DOM.
     *--------------------------------------------------------------------------------------------*/
    $(function() {
        
        /**
         * Overwrite the default field constraint violation error handler to use Notifie to display the errors above the individual fields.
         */
        bundle.config = {
            renderers: {
                fieldConstraintViolations: function(form, fieldConstraintViolations) {
                    _.each(fieldConstraintViolations, function(value, key){
                        $(form.getFieldByName(key).wrapper()).notifie({
                            message: value.join("<br>"),
                            exitEvents: "click"
                        });
                    });
                }
            }
        };
        
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
    
    
         
})($, _);