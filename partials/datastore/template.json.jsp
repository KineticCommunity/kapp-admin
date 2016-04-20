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
          "required": false,
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
          "visible": true,
          "enabled": true,
          "renderType": "submit-page",
          "renderAttributes": {}
        },
        {
          "type": "button",
          "label": "Cancel",
          "name": "Cancel",
          "visible": true,
          "enabled": true,
          "renderType": "custom",
          "renderAttributes": {},
          "events": [
            {
              "name": "Return to Datastore",
              "type": "Click",
              "action": "Custom",
              "code": "location.replace($('a.return-to-store').attr('href'));"
            }
          ]
        }
      ],
      "events": [
        {
          "name": "Return to Datastore on Success",
          "type": "Submit",
          "action": "Custom",
          "code": "if ($.isEmptyObject(event.constraints)){\n\tlocation.replace($('a.return-to-store').attr('href'));\n}"
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