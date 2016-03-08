## Overview
The bundle directory includes files that are needed for initialization and helper files for commonly used functionality. 

It includes:

* initialization.jspf
* router.jspf
* CategoryHelper.jspf
* SetupHelper.jspf
* SubmissionHelper.jspf

## CategoryHelper.jspf
Examples can be viewed at : <http://community.kineticdata.com/10_Kinetic_Request/Kinetic_Request_Core_Edition/Resources/Bundle_Category_Helper>

**${CategoryHelper.getCategories(Kapp kapp)}**  
Gathers, maps and sorts all Kapp categories / subcategories and returns an arraylist of BundleCategories.  
This list can be itterated over to retrieve the root category objects.  
Requires - Kapp object  
Returns - ArrayList<BundleCategory>  
  
**${CategoryHelper.getCategories(Form form)}**  
Gets categories that are set to a form.   
Requires - Form object  
Returns - ArrayList<BundleCategory>  
  
**${CategoryHelper.getCategory(Form form)}**  
Gets a single category object based on the name (not Display Name)   
Requires - Name string  
Returns - BundleCategory object  
  
**${category.getCategory()}**  
Returns the current category object  
  
**${category.getName()}**  
Returns the name string of the current category object  
  
**${category.getAttributes()}**  
Returns a list of attributes for the current category object  
  
**${category.getAttribute(String name)}**  
Returns the attribute object of the current category based on the name passed  
Requires - Name string  
Returns - Attribute Object  
  
**${category.getAttributeValue(String name)}**  
Returns a string value of the current category's attribute based on the attribute name passed  
Requires - Name string  
Returns - Value string  
  
**${category.getAttributeValues(String name)}**  
Returns list of string values for an attribute based on the attribute name passed  
Requires - Name string  
Returns - List<String>  
  
**${category.hasAttribute(String name)}**  
Returns true if the current category has the attribute (can be null) based on the attribute name passed  
Requires - Name string  
Returns - True / False  
  
**${category.hasAttribute(String name)}**  
Returns true if the current category has the passed name attribute with the value passed  
Requires - Attribute name string, attribute value string  
Returns - True / False  
  
**${category.getKapp()}**  
Returns the current category Kapp object  
  
**${category.getForms()}**   
Returns a list of form objects for the current category  
  
**${category.getDisplayName()}**  
Returns the "Display Name" attribute value if not null, otherwise returns name  
  
**${category.getParentCategory()}**  
Returns the parent category object  
  
**${category.setParentCategory(BundleCategory parentCategory)}**  
Sets the current category's parent category to the passed object  
  
**${category.getTrail()}**  
Returns an array of parent category objects sorted from the root category to current category  
  
**${category.getSubcategories()}**       
Returns the subcategory objects for the current category  
  
**${category.setSubcategory(BundleCategory bundleCategory)}**  
Adds the passed object as a subcategory of the current category  
  
**${category.hasSubcategories()}**  
Returns true if the current category has subcategories  

**${category.hasNonEmptySubcategories()}**  
Returns true if the current category has subcategories that have active forms  

**${category.hasForms()}**  
Returns true if the current category has active forms  

**${category.isEmpty()}**  
Returns true if the category and all subcategories do not have forms  

