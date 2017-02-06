// Ensure the BUNDLE global object exists
bundle = typeof bundle !== "undefined" ? bundle : {};
// Create namespace for Admin Notification Console
bundle.adminNotifications = bundle.adminNotifications || {};
// Your method
  
bundle.adminNotifications.getUrlVars = function() {
    var vars = [], hash;
    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
    for(var i = 0; i < hashes.length; i++)
    {
        hash = hashes[i].split('=');
        vars.push(hash[0]);
        vars[hash[0]] = decodeURIComponent(hash[1]);
    }
    return vars;
}