{
  "anonymous": false,
  "attributes": [
    {
      "name": "Datastore Configuration",
      "values": [
        "[]"
      ]
    }
  ],
  "pages": [
    {
      "advanceCondition": "false",
      "displayCondition": null,
      "displayPage": "pages/datastore/datastoreForm.jsp",
      "elements": [
        {
          "type": "field",
          "name": "Status",
          "label": "Status",
          "key": "f1",
          "defaultValue": null,
          "defaultResourceName": null,
          "visible": true,
          "enabled": true,
          "required": true,
          "requiredMessage": null,
          "omitWhenHidden": null,
          "pattern": null,
          "constraints": [],
          "events": [],
          "renderAttributes": {},
          "dataType": "string",
          "renderType": "radio",
          "choicesResourceName": null,
          "choicesRunIf": null,
          "choices": [
            {
              "label": "Active",
              "value": "active"
            },
            {
              "label": "Inactive",
              "value": "inactive"
            }
          ]
        },
        {
          "type": "field",
          "name": "Sample Field",
          "label": "Sample Field",
          "key": "fSample",
          "defaultValue": null,
          "defaultResourceName": null,
          "visible": true,
          "enabled": true,
          "required": false,
          "requiredMessage": null,
          "omitWhenHidden": null,
          "pattern": null,
          "constraints": [],
          "events": [],
          "renderAttributes": {},
          "dataType": "string",
          "renderType": "text",
          "rows": 1
        },
        {
          "type": "button",
          "label": "Save",
          "name": "Save",
          "visible": "bundle.adminDatastore != null",
          "enabled": true,
          "renderType": "submit-page",
          "renderAttributes": {
            "class": "btn btn-primary"
          }
        },
        {
          "type": "button",
          "label": "Cancel",
          "name": "Cancel",
          "visible": "bundle.adminDatastore != null",
          "enabled": true,
          "renderType": "custom",
          "renderAttributes": {
            "class": "btn btn-link"
          },
          "events": [
            {
              "name": "Return to Datastore",
              "type": "Click",
              "action": "Custom",
              "code": "location.href=$('a.return-to-store').attr('href');"
            }
          ]
        }
      ],
      "events": [
        {
          "name": "Return to Datastore on Success",
          "type": "Submit",
          "action": "Custom",
          "code": "if ($.isEmptyObject(event.constraints)){\n\tlocation.href=$('a.return-to-store').attr('href');\n}"
        }
      ],
      "name": "Datastore",
      "renderType": "submittable",
      "type": "page"
    }
  ],
  "status": "Active",
  "type": "Datastore"
}