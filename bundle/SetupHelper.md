## Overview

The SetupHelper is a utility for predefining configurations that are required to exist in order for 
the Kapp to function. If the Kapp is not configured, or is missing required attributes, the setup 
page will be shown instead of the page the user wants to see. The Setup Wizard, which is accessible 
from the setup page, uses the defined configurations to guide the user through configuring the Kapp.   

The Setup page and Setup Wizard are only available to Space Admins. If the Kapp is not configured, 
regular users will get an error stating that the Kapp is not configured and requesting that they 
contact an adminstrator. If the Kapp is configured and valid, regular users will get an error 
stating they do not have access to the page.

## Files

[bundle/SetupHelper.md](SetupHelper.md)  
README file containing information on configuring and using the setup helper.

[bundle/SetupHelper.jspf](SetupHelper.jspf)  
Helper file containing definitions for the SetupHelper.  More information can be found in
the [SetupHelper Summary](#setuphelper-summary) section.

[setup/setup.jsp](setup.json)  
Json Object which defines all required configurations.

[setup/README.md](README.md)  
README file containing information about the setup wizard, and information about how to create the setup.json file. 

[setup/setup.jsp](setup.jsp)  
Page that shows if Kapp is configured and displays all available attributes used for configuring the Kapp. 

[setup/wizard.jsp](wizard.jsp)  
Page that guides the user through creating all the required configuration components defined in the setup.json file.

[setup/setup.js](setup.js)  
JavaScript code for the setup.jsp and wizard.jsp pages.

[setup/setup.css](setup.css)  
CSS for the setup.jsp and wizard.jsp pages.

[setup/wizard/adminKappForms.jsp](adminKappForms.jsp)  
[setup/wizard/attributes.jsp](attributes.jsp)  
[setup/wizard/bridges.jsp](bridges.jsp)  
[setup/wizard/categories.jsp](categories.jsp)  
[setup/wizard/forms.jsp](forms.jsp)  
[setup/wizard/formTypes.jsp](formTypes.jsp)  
[setup/wizard/navigation.jsp](navigation.jsp)  
[setup/wizard/progress.jsp](progress.jsp)  
[setup/wizard/security.jsp](security.jsp)  
[setup/wizard/webhooks.jsp](webhooks.jsp)  
Partials used by the Setup Wizard to display the individual components that need to be configured.


## Configuration

* Copy the files listed above into your bundle
* Initialize the SetupHelper in your bundle/initialization.jspf file
* Modify the router.jspf file to redirect when configuration is not valid or required attributes are missing

### Initialize the SetupHelper

**bundle/initialization.jspf**
```jsp
<%-- SetupHelper --%>
<%@include file="SetupHelper.jspf"%>
<%
    SetupHelper setupHelper = new SetupHelper(request);
    request.setAttribute("SetupHelper", setupHelper);
%>
```

### Modify the router.jspf file to redirect when required attributes are missing

In order to leverage all features of the SetupHelper in a bundle, some additional routing needs to be added to the
beginning of the `bundle/router.jsp` file.  The following code can be copied and pasted directly below the section 
which defines the `String delegateJsp`.

**bundle/router.jsp**  
Insert this code:
```jsp
<%-- INVALID CONFIGURATION ROUTING --%>
<%
    // If the request is scoped to a specific Kapp (space display pages are not)
    if (kapp != null) {
        // If kapp is not configured, there are missing required attributes, or setup parameter is present
        if (setupHelper.routeToSetup() != null) {
            // Render the setup page (this will show the full setup page if the user is a space 
            // admin, or it will show a generic error message if they are not)
            try {
                delegateJsp = bundle.getPath()+"/setup/"+setupHelper.routeToSetup()+".jsp";
                request.getRequestDispatcher(delegateJsp).include(request, response);
            }
            catch (ServletException e){
                // If the specified delegate JSP doesn't exist
                /** This is looking for a Tomcat specific error message **/
                if (e.getMessage() != null && e.getMessage().trim().matches("^File \\[.+\\] not found$")) {
                    // Simulate a 404 not found
                    request.setAttribute("javax.servlet.error.message", delegateJsp);
                    response.setStatus(response.SC_NOT_FOUND);
                    request.getRequestDispatcher("/WEB-INF/pages/404.jsp").include(request, response);
                }
                else { throw e; }
            }
            // Return so that no further JSP processing occurs
            return;
        }
    }
%>
```
Immediately after this section:
```jsp
<%
    // String to store the path to the JSP that the response should be delegated to
    String delegateJsp = null;
%>
```

---

#### SetupHelper Summary
Parses and initializes the required configurations for the Kapp.

###### Constructors
`SetupHelper(HttpServletRequest request)`  

###### Helpers
`String getWizardNextStep(String currentStep)`  
`String getWizardPreviousStep(String currentStep)`  
`List<LinkedHashMap> getWizardProgress()`  
`boolean isWizardLastStep(String currentStep)`  
`String routeToSetup()`   
`void updateKappConfigurationStatus()`  

###### Getters
`Kapp getAdminKapp()`  
`List<ConfigForm> getAdminKappForms()`  
`List<ConfigBridge> getBridges()`  
`List<ConfigBridgeModel> getBridgeModels()`  
`List<ConfigCategory> getCategories()`  
`List<ConfigAttributeDefinition> getCategoryAttributeDefinitions()`  
`List<ConfigAttributeDefinition> getFormAttributeDefinitions()`  
`List<ConfigForm> getForms()`  
`List<ConfigFormType> getFormTypes()`  
`List<ConfigAttributeDefinition> getKappAttributeDefinitions()`  
`List<ConfigWebhook> getKappWebhooks()`  
`List<ConfigSecurityPolicy> getSecurityPolicies()`  
`List<ConfigSecurityPolicyDefinition> getSecurityPolicyDefinitions()`  
`List<ConfigAttributeDefinition> getSpaceAttributeDefinitions()`  
`List<ConfigWebhook> getSpaceWebhooks()`  
`List<ConfigAttributeDefinition> getUserAttributeDefinitions()`  
`boolean isAdminExists()`  
`boolean isAdminRequired()`  
`boolean isAdminValid()`  
`boolean isConfigured()`  
`boolean isExists()`  
`boolean isMissingAttributes()`  
`boolean isValid()`  

---

#### ConfigAttributeDefinition Summary
Custom model to store configuration for Attribute Definitions

###### Constructors
`<A extends ModelWithAttributes> ConfigAttributeDefinition(LinkedHashMap<String, Object> attribute, A attributeContext, boolean definitionExists)`  

###### Helpers
`List<String> getMissingDefaultValues()`  
`boolean hasAttributeValue(String value)`  
`boolean hasAttributeValues()`  

###### Getters 
`ConfigAttribute getAttribute()`  
`ConfigAttribute getDefaultAttribute()`  
`String getDescription()`  
`String getName()`  
`boolean isValid()`  
`boolean isApplicable()`  
`boolean isRequired()`  
`boolean isAllowsMultiple()`  
`boolean isMissingValues()`  
`boolean isDefinitionExists()`  

---

#### ConfigAttribute Summary
Custom model to store configuration for Attribute Values

###### Constructors
`<A extends ModelWithAttributes> ConfigAttribute(LinkedHashMap<String, Object> attribute, A attributeContext)`  
`ConfigAttribute(String name, List<String> values)`  

###### Helpers
`boolean hasValue(String value)`  

###### Getters 
`String getName()`  
`List<String> getValues()`  

---

#### ConfigBridge Summary
Custom model to store configuration for Bridges

###### Constructors
`ConfigBridge(LinkedHashMap<String, String> bridge, Space space)`  

###### Getters 
`String getName()`  
`String getStatus()`  
`String getUrl()`  
`boolean isExists()`  

---

#### ConfigBridgeModel Summary
Custom model to store configuration for Bridge Models

###### Constructors
`ConfigBridgeModel(LinkedHashMap<String, Object> bridgeModel, Space space)`  

###### Getters 
`String getActiveMappingName()`  
`List<ConfigBridgeModelAttribute> getAttributes()`  
`List<ConfigBridgeModelMapping> getMappings()`  
`String getName()`  
`List<ConfigBridgeModelQualification> getQualifications()`  
`String getStatus()`  
`boolean isExists()`  
`boolean isMappingsExist()`  

---

#### ConfigBridgeModelAttribute Summary
Custom model to store configuration for Bridge Model Attributes

###### Constructors
`ConfigBridgeModelAttribute(LinkedHashMap<String, String> bridgeModelAttribute)`  

###### Getters 
`String getName()`  

---

#### ConfigBridgeModelMapping Summary
Custom model to store configuration for Bridge Model Mappings

###### Constructors
`ConfigBridgeModelMapping(LinkedHashMap<String, Object> bridgeModelMapping, BridgeModel bridgeModel)`  

###### Getters 
`List<ConfigBridgeModelMappingAttribute> getAttributes()`  
`String getBridgeName()`  
`String getName()`  
`List<ConfigBridgeModelMappingQualification> getQualifications()`  
`String getStructure()`  
`boolean isExists()`  

---

#### ConfigBridgeModelMappingAttribute Summary
Custom model to store configuration for Bridge Model Mapping Attributes

###### Constructors
`ConfigBridgeModelMappingAttribute(LinkedHashMap<String, String> bridgeModelMappingAttribute)`  

###### Getters 
`String getName()`  
`String getStructureField()`  

---

#### ConfigBridgeModelQualification Summary
Custom model to store configuration for Bridge Model Qualifications

###### Constructors
`ConfigBridgeModelQualification(LinkedHashMap<String, Object> configBridgeModelQualification)`  

###### Getters 
`String getName()`  
`String getResultType()`  
`List<ConfigBridgeModelQualificationParameter> getParameters()`  

---

#### ConfigBridgeModelQualificationParameter Summary
Custom model to store configuration for Bridge Model Qualification Parameters

###### Constructors
`ConfigBridgeModelQualificationParameter(LinkedHashMap<String, String> configBridgeModelQualificationParameter)`  

###### Getters 
`String getName()`  

---

#### ConfigBridgeModelMappingQualification Summary
Custom model to store configuration for Bridge Model Mapping Qualifications

###### Constructors
`ConfigBridgeModelMappingQualification(LinkedHashMap<String, String> bridgeModelMappingQualification)`  

###### Getters 
`String getName()`  
`String getQuery()`  

---

#### ConfigCategory Summary
Custom model to store configuration for Categories

###### Constructors
`ConfigCategory(LinkedHashMap<String, String> category)`  

###### Getters 
`String getName()`  
`String getSlug()`  

---

#### ConfigForm Summary
Custom model to store configuration for Forms

###### Constructors
`ConfigForm(LinkedHashMap<String, Object> form, Kapp kapp)`  

###### Helpers
`boolean hasFormDefinition()`  

###### Getters 
`boolean isAnonymous()`  
`List<ConfigAttribute> getAttributes()`  
`List<LinkedHashMap> getBridgedResources()`  
`List<LinkedHashMap> getCategorizations()`  
`String getCustomHeadContent()`  
`String getDescription()`  
`String getName()`  
`String getNotes()`  
`List<LinkedHashMap> getPages()`  
`List<ConfigSecurityPolicy> getSecurityPolicies()`  
`String getSlug()`  
`String getStatus()`  
`String getSubmissionLabelExpression()`  
`String getType()`  
`boolean isExists()`  

---

#### ConfigFormType Summary
Custom model to store configuration for Form Types

###### Constructors
`ConfigFormType(LinkedHashMap<String, String> formType)`  

###### Getters 
`String getName()`  

---

#### ConfigSecurityPolicyDefinition Summary
Custom model to store configuration for Security Policy Definitions

###### Constructors
`ConfigSecurityPolicyDefinition(LinkedHashMap<String, String> securityPolicyDefinition)`  

###### Getters 
`String getMessage()`  
`String getName()`  
`String getRule()`  
`String getType()`  

---

#### ConfigSecurityPolicy Summary
Custom model to store configuration for Security Policies

###### Constructors
`ConfigSecurityPolicy(LinkedHashMap<String, String> securityPolicy)`  

###### Getters 
`String getName()`  
`String getEndpoint()`  

---

#### ConfigWebhook Summary
Custom model to store configuration for Webhooks

###### Constructors
`ConfigWebhook(LinkedHashMap<String, String> webhook)`  

###### Getters 
`String getEvent()`  
`String getFilter()`  
`String getName()`  
`String getType()`  
`String getUrl()`  