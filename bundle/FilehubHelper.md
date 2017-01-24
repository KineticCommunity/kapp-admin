## Overview

The FilehubHelper utility class is used to integrate bundle requests with Kinetic Filehub, allowing
users to display or download files stored in external systems.

Kinetic Filehub is a web application used to provide a consistent interface for storing and 
retrieving files.  It is installed with a set of Filehub Adapters, which provide the functionality
necessary to read and write to external systems.  Example adapters include an Amazon S3 adapter, Ars
adapter, Database adapter, and Local Filesystem adapter.  In addition to pre-installed adapters, it 
is possible to write custom adapters for interacting with other systems.

Kinetic Filehub delegates file access authorization by pre-sharing access keys with integrating 
applications.  An access key "secret" can be used to create a cryptographic signature of an HTTP 
request (which could be to download, upload, or delete a file).  When a request is made, Kinetic
Filehub validates the signature and that the request has not expired before proceeding.

Once configured, a bundle expose files in external filestores by building up links similar to:

```jsp
<a href="${bundle.kappLocation}?filestore=knowledge-management&path=${path}"
    >${text.escape(filename)}</a>
```

or 

```jsp
<a href="${bundle.kappLocation}?filestore=db&table=employee_images&record=653325&column=image"
    >${text.escape(filename)}</a>
```

These URLs are intercepted by the `bundle/router.jspf` file (which is looking for the "filestore"
parameter), which then uses the parameters to authorize access and respond with a 302 redirect to 
the signed Kinetic Filehub URL.

## Files

[bundle/FilehubHelper.md](FilehubHelper.md)  
README file containing information on configuring and using the filehub helper.

[bundle/FilehubHelper.jspf](FilehubHelper.jspf)  
Helper file containing definitions for the FilehubHelper.  More information can be found in the 
[FilehubHelper Summary](#filehubhelper-summary) section.


## Configuration

* Copy the files listed above into your bundle
* Initialize the FilehubHelper in your bundle/initialization.jspf file
* Add setup attributes that are used by the helper
* Modify the router.jspf file to handle filestore requests

### Initialize the FilehubHelper

Each bundle may have a different way to obtain the filehub url and filestore slugs/keys/secrets, and 
each filestore will have a different way of determining access authorization and building up the 
filestore request paths, but the initialization code should look something like:

**bundle/initialization.jspf**
```jsp
<%-- FilehubHelper --%>
<%@include file="FilehubHelper.jspf"%>
<%
    // Declare the filehubHelper, which is referenced in the router.jspf file
    FilehubHelper filehubHelper = null;
    // If the request is scoped to a specific Kapp (space display pages are not)
    if (kapp != null && kapp.hasAttribute("Filehub Url")) {
        // Initialize the filehub helper
        filehubHelper = new FilehubHelper(kapp.getAttributeValue("Filehub Url"));

        // Initialize the "Example" filestore
        if (kapp.hasAttribute("Example Filestore Slug")) {
            filehubHelper.addFilestore(
                kapp.getAttributeValue("Example Filestore Slug"),
                kapp.getAttributeValue("Example Filestore Key"),
                kapp.getAttributeValue("Example Filestore Secret"),
                new FilehubHelper.Authorizer() {
                    @Override public boolean canAccess(HttpServletRequest request) {
                        return true;
                    }
                },
                new FilehubHelper.PathBuilder() {
                    @Override public String buildPath(HttpServletRequest request) {
                        //return request.getParameter("path");
                        String path = request.getParameter("form")+
                            "/"+request.getParameter("entry")+
                            "/"+request.getParameter("field");
                        if (request.getParameter("filename") != null) {
                            path += "/"+request.getParameter("filename");
                        }
                        return path;
                    }
                }
            );
        }
    }
%>
```

### Add Kapp Setup Attributes 
*(Include in `setup\setup.json` if using setup wizard)*
```js
{
    "name": "Filehub Url",
    "allowsMultiple": false,
    "description": "The URL to the Kinetic Filehub application (https://acme.com/kinetic-filehub)",
    "required": false
}
```
The example above also used the below attributes, which will likely have different names for your implementation:
```js
{
    "name": "Example Filestore Slug",
    "allowsMultiple": false,
    "description": "The slug of the desired filestore configured in Kinetic Filehub.",
    "required": false
}
{
    "name": "Example Filestore Key",
    "allowsMultiple": false,
    "description": "The key for an access key associated to the specified filestore.",
    "required": false
}
{
    "name": "Example Filestore Secret",
    "allowsMultiple": false,
    "description": "The secret associated to the specified key.",
    "required": false
}
```

### Modify the router.jspf file to handle filestore requests

In order to leverage the FilehubHelper in a bundle, some additional routing needs to be added to the
end of the `bundle/router.jsp` file.  The following code can be copied and pasted directly.

**bundle/router.jsp**
```jsp
<%-- FILEHUB ROUTING --%>
<%
    // If there is a request for a configured filestore
    if (request.getParameter("filestore") != null) {
        // Obtain a reference to the filestore
        FilehubHelper.Filestore filestore = filehubHelper.getFilestore(request.getParameter("filestore"));
        // If the filestore doesn't exist
        if (filestore == null) {
            // Simulate a 404 not found response
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            request.setAttribute("message", "The \""+request.getParameter("filestore")+"\" "+
                "filestore was not found.");
            request.getRequestDispatcher("/WEB-INF/pages/404.jsp").include(request, response);
        }
        // If access is allowed
        else if (filestore.canAccess(request)) {
            // Build the redirection URL
            String url = filehubHelper.url(
                filestore.getSlug(), filestore.buildPath(request), request.getParameter("filename"));
            // Configure the response to redirect
            response.setStatus(HttpServletResponse.SC_MOVED_TEMPORARILY);
            response.setHeader("Location", url);
        }
        // If access is not allowed and the user is authenticated
        else if (identity.isAuthenticated()) {
            // Simulate a 403 forbidden response
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            request.setAttribute("message", filestore.buildPath(request));
            request.getRequestDispatcher("/WEB-INF/pages/403.jsp").include(request, response);
        }
        // If access is not allowed and the user is anonymous
        else {
            // Simulate a 401 unauthenticated response
            response.setStatus(HttpServletResponse.SC_MOVED_TEMPORARILY);
            response.setHeader("Location", 
                bundle.getSpaceLocation()+"/app/login"+(kapp == null ? "" : "?kapp="+kapp.getSlug()));
        }
        // Return so that no further JSP processing occurs
        return;
    }
%>
```

---

#### FilehubHelper Summary

`FilehubHelper(String baseUrl)`  

`FilehubHelper addFilestore(String filestoreSlug, String key, String secret, 
    FilehubHelper.Authorizer authorizer, FilehubHelper.PathBuilder pathBuilder)`  

`FilehubHelper.Filestore getFilestore(String filestoreSlug)`  
`String url(String filestoreSlug, String path)`  
`String url(String filestoreSlug, String path, String filenameOverride)`  

---

#### FilehubHelper.Filestore Summary

`Filestore(String slug, String key, String secret, Authorizer authorizer, PathBuilder pathBuilder)`  

`String buildPath(HttpServletRequest request)`  
`boolean canAccess(HttpServletRequest request)`  
`String getKey()`  
`String getSecret()`  
`String getSlug()`  