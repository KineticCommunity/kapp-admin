## Overview
This bundle implements various Admin Consoles which offer functionality for maintaining data not available (or is more difficult) in the Request Management Console.

It includes the following Admin Console:

* Attributes: Manage attributes, including the ability to add complex JSON attributes.
* Categories: Manage categories and subcategories.
* Message Templates: Manage email templates.
* Translations: Manage multi-lingual translations.

## Personalization
This bundle easily allows for minor personalization by including optional attributes in your KAPP, Form and/or Categories.

#### Setup Initialization
This base bundle has _Required Attributes_ that utilizes Kinetic Task. To edit or add Required Attributes, you define and initialize attribute's in the intilialization.jspf. You can view this Kapp configuration by viewing the passing the parameter in the url, i.e. (http://localhost:8080/kinetic/kappName?partial=setup).

#### KAPP Attributes
* _Exclude Console_ : Specify consoles that should not be available.

## Customization
When you customize this bundle it is a good idea to fork it on your own git server to track your customizations and merge in any code changes we make to the default.

We also suggest you update this README with your own change summary for future bundle developers.

## Adding New Consoles
To add a new console, complete the following steps. In the examples, we will be adding a Categories console.

#####1. Define the new console in `/bundle/initialization.jspf`
```
AdminHelper adminHelper = new AdminHelper() // This line will already exist
    .addAdminConsole("Categories", // Name
        "Manages categories and subcategories.", // Description
        "categories", // Slug 
        "console"); // Home Page 
```
The **Name** of the console is what will appear in links and headers. It is also the value that needs to be added as an _Exclude Console_ Attribute in order to not show the console.  
The **Description** defines the console functionality. This will appear on the Admin Console home page.  
The **Slug** is the name of the subfolders which contain all files for this console, and exist in each of the following folders: _pages_, _partials_, _js_, _css_, and _images_.  
The **Home Page** is the name of a file inside the _slug_ subfolder of the _pages_ folder. This is the page that will be shown when the user first opens the console.  

#####2. Create the folders to store the files specific to your new console. Our slug is _categories_ so that is what our folders will be named. Also create the base files required to get started. 
###### This bundle contains files for a console with the slug _templates_. These files are meant to be used as templates and are a great starting point.
```
/*bundle-name*
  /*css*
    /*categories*: Create this folder.
      /*categories.css*: Create this file to store all CSS specific to your new console. 
  /*images*
    /*categories*: Create this folder.
  /*js*
    /*categories*: Create this folder.
      /*categories.js*: Create this file to store all JavaScript specific to your new console. 
  /*pages*
    /*categories*: Create this folder.
      /*console.jsp*: Create a copy of _/partials/templates/console.jsp_
  /*partials*
    /*categories*: Create this folder.
      /*head.jsp*: Create a copy of _/partials/templates/head.jsp_
      /*navbar.jsp*: Create a copy of _/partials/templates/navbar.jsp_
```

#####3. Update the newly created _head.jsp_ file to point to the correct CSS and JavaScript files for your new console.

#####4. Update the newly created _navbar.jsp_ file to point to the correct pages for your new console.
```
<li class="${text.equals(param.page, 'templates/console') ? 'active' : ''}">
    <a href="${bundle.kappLocation}?page=templates/console">Home</a>
</li>
```
######_should be changed to:_
```
<li class="${text.equals(param.page, 'categories/console') ? 'active' : ''}">
    <a href="${bundle.kappLocation}?page=categories/console">Home</a>
</li>
```

#####5. The _console.jsp_ file also uses the _/partials/sidebarKapps.jsp_ file to build a list of links for each Kapp in the left sidebar. 
######You can customize this sidebar by creating a _sidebar.jsp_ file in your _/partials_ folder and updating _console.jsp_ to point to the new file instead.

#####6. You are done! You can modify _console.jsp_ to change the content of your console page and include/delete code necessary to show/remove the different levels of navigation. 
###### Go to your Admin Console and open your new console from the dropdown menu in the top left!

## Structure
This default bundle uses our standard directory structure.  Bundles are completely self contained so should include all libraries and markup needed.

<code><pre>
/*bundle-name*
  /*bundle*: Initialization scripts and helpers
  /*css*: Cascading style sheets. If you use Sass, check our the scss directory here.
    /*console-slug*: CSS files specific to the console with slug _console-slug_ go here.
  /*images*: Duh.
    /*console-slug*: Images specific to the console with slug _console-slug_ go here.
  /*js*: All javascript goes here.
    /*console-slug*: Javascript files specific to the console with slug _console-slug_ go here.
  /*layouts*: One or more layouts wraps your views and generally includes your HTML head elements and any content that should show up on all pages.
  /*libraries*: Include CSS, JS or other libraries here including things like JQuery or bootstrap.
  /*pages*:  Individual page content views. In our example we have a profile.jsp and search.jsp.
    /*console-slug*: Individual page content views specific to the console with slug _console-slug_ go here.
  /*partials*: These are view snippets that get used in the top-layer JSP views.
    /*console-slug*: View snippets specific to the console with slug _console-slug_ go here.
    /*sidebarKapps.jsp*: Partial which loads links to all Kapps into the lefthand sidebar when used.
  /*confirmation.jsp*: The default confirmation page on form submits.
  /*form.jsp*: The default form JSP wrapper.
  /*kapp.jsp*: This is the Admin Console home page. It lists all available consoles with their descriptions.
  /*login.jsp*: The default login page. Can be overridden in your Space Admin Console.
  /*resetPassword.jsp*: The default reset password page. This will trigger the system to send an email to the user to reset their password. Note that the SMTP server needs to be configured to work.
</pre></code>
