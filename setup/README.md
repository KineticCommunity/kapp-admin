## Overview

This setup folder contains the files for the Setup page and Setup Wizard.

## Setup Json Structure

The setup.json file can have the following structure. If the file exists, it must be valid json. All of the properties are optional.

```js
{
    "spaceAttributeDefinitions": [],
    "kappAttributeDefinitions": [],
    "formAttributeDefinitions": [],
    "categoryAttributeDefinitions": [],
    "userAttributeDefinitions": [],
    "bridges": [],
    "bridgeModels": [],
    "categories": [],
    "formTypes": [],
    "forms": [],
    "securityPolicyDefinitions": [],
    "securityPolicies": [],
    "spaceWebhooks": [],
    "kappWebhooks": [],
    "adminKapp": {
        "forms": []
    }
}

```

## Dynamic Value Replacement

In the creation of the setup.json, you may use the following four dynamic values, which will be converted to their actual values when the file is read.

* __{{kapp.slug}}__ `This will evaluate to the slug of the Kapp you are configuring.`
* __{{kapp.name}}__ `This will evaluate to the name of the Kapp you are configuring.`
* __{{adminKapp.slug}}__ `This will evaluate to the slug of the Admin Kapp, if it exists.`
* __{{adminKapp.name}}__ `This will evaluate to the name of the Admin Kapp, if it exists.`

This is useful for defining default attribute values, bridge qualification queries, etc.

## Json Creation

There are two ways to create the setup.json file.

* __Manual Json Creation:__ Write the file manually, by exporting the Space and Kapp, pulling out the required pieces, and piecing them together to create the above structure.
* __Setup Json Generator:__ Download and use the generator which will allow you to convert a build Kapp into json by selecting the components you want. 

### Manual Json Creation
Create the setup.json file and piece together the required components. Below you will find samples for the structure of each component.

#### Sample Json Values
Each array in the above structure accepts objects which correspond with the core models and the output produced by the REST API.

##### spaceAttributeDefinitions, kappAttributeDefinitions, formAttributeDefinitions, categoryAttributeDefinitions, userAttributeDefinitions
Attribute Definitions allow for two additional properties, `required` and `values`. 
```js
{
    "name": "Attribute Name", 
    "allowsMultiple": false, 
    "required": true, // Whether an attribute value is required to exist for the page to load (Space, Kapp, and Form levels only)
    "description": "Description text.", 
    "values": ["defaultValue"] // Optional default value(s) that will appear in the Setup Wizard (Space and Kapp levels only)
}
```

##### bridges
```js
{
    "name": "Bridge Name", 
    "status": "Active", 
    "url": "http://localhost:8080/kinetic-bridgehub/app/api/v1/bridges/bridgename/" 
}
```

##### bridgeModels
```js
{
    "activeMappingName": "Mapping Name",
    "attributes": [
        {
            "name": "Attribute Name"
        }
    ],
    "mappings": [
        {
            "attributes": [
                {
                    "name": "Attribute Name",
                    "structureField": "${fields('values[Field Name]')}"
                }
            ],
            "bridgeName": "Bridge Name",
            "name": "Mapping Name",
            "qualifications": [
                {
                    "name": "Query",
                    "query": "kappSlug=kSlug&formSlug=fSlug&limit=999&values[Field Name]=${parameters('Param Name')}"
                }
            ],
            "structure": "Submissions"
        }
    ],
    "name": "Model Name",
    "qualifications": [
        {
            "name": "Query",
            "parameters": [
                {
                    "name": "Param Name",
                    "notes": null
                }
            ],
            "resultType": "Multiple"
        }
    ],
    "status": "Active"
}
```

##### categories
```js
{
    "name": "Category Name",
    "slug": "category-slug"
}
```

##### formTypes
```js
{
    "name": "Form Type"
}
```

##### forms
```js
{
    "anonymous": false,
    "attributes": [
    {
        "name": "Attribute Name",
        "values": ["Attribute Value(s)"]
    }
    ],
    "bridgedResources": [
        {
            "model": "Model Name",
            "name": "Bridged Resource Name",
            "parameters": [
                {
                    "mapping": "${values('Field Name')}",
                    "name": "Param Name"
                }
            ],
            "qualification": "Query",
            "status": "Active"
        }
    ],
    "categorizations": [
        {
            "category": {
                "slug": "category-slug"
            }
        }
    ],
    "customHeadContent": null,
    "description": "Description of form.",
    "name": "Form Name",
    "notes": null,
    "pages": [], // Export existing form and copy exact pages structure.
    "securityPolicies": [
        {
            "endpoint": "Form Security Endpoint",
            "name": "Security Policy Name"
        }
    ],
    "slug": "form-slug",
    "status": "Active",
    "submissionLabelExpression": null,
    "type": "Service"
}
```

##### securityPolicyDefinitions
```js
{
    "message": "Security policy message.",
    "name": "Security Policy Name",
    "rule": "true", 
    "type": "Kapp"
}
```

##### securityPolicies
```js
{
    "endpoint": "Kapp Security Endpoint",
    "name": "Security Policy Name"
} 
```

##### spaceWebhooks, kappWebhooks
```js
{
    "event": "Login",
    "filter": "",
    "name": "Webhook name",
    "type": "User",
    "url": "#"
}
```

##### adminKapp
The adminKapp property must be an object, and not an array like all other properties. 
If the adminKapp object exists (even if empty), then the Admin Kapp will be required. 
Furthermore, the adminKapp object may contain an array of forms which will be required.  

The adminKapp.forms array may contain two types of forms.  

__Forms that will be created inside the Admin Kapp if they don't yet exist.__  
To add a form that will be created by the Setup Wizard, add a form object that included 
the entire form object as shown in the forms sample above. This object must include the pages property.  

__Forms that are expected to already exist in the Admin Kapp and will *not* be created.__  
Some forms, such as the ones that are created as part of the Admin Kapp installation (categories, datastore, etc),
may be required to exist, but shouldn't be created from the Setup Wizard of a different Kapp. 
To define these dependencies, you need to add a reduced form object, as defined below. 
This object *cannot* include the pages property.  
```js
{
    // All other properties
    "adminKapp": {
        "forms": [
            {
                // Full form definition as seen above in the forms sample
            },
            {
                // Reduced form object. Only needs the below fields (slug is required and the others are optional).
                "description": "Description of form.",
                "name": "Form Name",
                "slug": "form-slug",
                "status": "Active",
                "type": "Service"
            }
        ]
    }
}
```

### Setup Json Generator

Instead of manually creating the setup.json file, you can generate it using the data of a Space and Kapp that is already configured. 
You will be able to see all the possible components that can be included in the json file, and then be able to remove the ones you don't want. 
Once you remove anything you don't want, you simply copy the generated json and save it into the setup.json file.   

**1.** Download the Setup Json Generator bundle and add it to the space folder where all your other bundles reside.  
**2.** Go to the Kapp Management Console and select the Setup Tab.  
**3.** Change the Bundle Path field to point to the Setup Json Generator bundle that you added to your space.  
**4.** Click the View Kapp button to launch the Setup Json Generator.  
**5.** Use the generator to select the necessary pieces and generate the json.  
**6.** Copy the json from the generator and save it into a setup.json file.  
**7.** Return to the Setup Tab of the Kapp Managament Console and change the Bundle Path field back to it's original value.  