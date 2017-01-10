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
            "class": "btn btn-tertiary"
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
            "class": "btn btn-link cancel-record"
          },
          "events": []
        }
      ],
      "events": [],
      "name": "Datastore",
      "renderType": "submittable",
      "type": "page"
    }
  ],
  "status": "Active",
  "type": "Datastore"
}