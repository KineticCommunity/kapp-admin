/* JS for the header functionality */
(function($, _) {
    /**---------------------------------------------------------------------------------------------
     * DOM MANIPULATION AND EVENT REGISTRATION 
     *   This section is executed on page load to register events and otherwise manipulate the DOM.
     *--------------------------------------------------------------------------------------------*/
    $(function() {
        
    });

    /**---------------------------------------------------------------------------------------------
     * COMMON INIALIZATION 
     *   This code is executed when the Javascript file is loaded
     *--------------------------------------------------------------------------------------------*/
    // Ensure the BUNDLE global object exists
    bundle = typeof bundle !== "undefined" ? bundle : {};
    // Create public namespace for header
    bundle.header = bundle.header || {};
    _.templateSettings = {interpolate: /\{\{(.+?)\}\}/g};

    // Create a private namespace for the header methods
    var header = bundle.header;//{};
    
    
        
})($, _);