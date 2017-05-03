/**
* Prerequisates to using this script are
* jQuery / underscore / moment
*/

/**
* TO IMPLEMENT:
* 1. Configure the required attributes on any HTML element within any Kinetic Form
* 3. Create an on load event to call the typeAheadSearch() function OR call the typeAheadSearch() function from within the bundle.config's ready callback in your bundle
* 4. Add this code to custom head content, or include it within your form's jsp
* 5. Add the css (at the bottom of this file) to custom head content, or include it within your form's jsp
*/

/**
* DESCRIPTION
* kd-subforms is meant for making it easy to display subforms within other Kinetic Forms
* 
* The typeahead functionality is implemented on any HTML element with an attribute called "uses-subform". Additional input attributes can be specified to 
* allow form builders to manipulate the subform / table behavior. 
* 
* There is a default configuration object that is used for each subform search. It can be overridden by a custom configuration object added to the bundle 
* or to the forms custom head content. Additional attributes can be added to the html element that will override the custom or default configuration object.
*/

/*------------------------------------------------------------
* TYPEAHEAD SEARCH INPUT ATTRIBTUES: 
* uses-subform                 *REQUIRED      (attribute applied to an html element that specifies that this table is being built via a subform ex. 'yes')
* subform-slug                 *REQUIRED      (slug of the subform to load)
* subform-config-object        *OPTIONAL      (Configuration object to use in lieu of the default configuration)
* subform-columns              *OPTIONAL      (Comma separated Column Name to Field on Subform mapping. Defaults to all visible subform fields) (e.g. Column Name1=Subform Field1,Column Name2=Subform Field2)
* subform-modal                *OPTIONAL      (Name of Bridge Attribute to Set in Typeahead Search Field) (e.g. Name)
* subform-empty-message        *OPTIONAL      (When there are no subform records to show in the table, this message is displayed in the table)
*/




(function($, _, moment){
    // create the subformTables global object
    subformTables = typeof subformTables === "undefined" ? {} : subformTables;
    // Create initialize function (called from bundle ready function, or on load event)
    subformTables.initialize = function(form){
        // On Load Event that Searches the current form for "uses-subform" input attribute
        $(form.element()).find('div[uses-subform]').each(function(){
            
            // Set Subform Container Div
            var subformDiv = $(this)
            // Setup Config Variables for Subform
            var subformConfig = $.extend(true, {}, subformConfigurations['defaultConfiguration'])
            // Check to see if there is a subform config object being specified
            if($(subformDiv).attr('subform-config-object') !== undefined){
                // If so, set the subformConfig to the specified config object
                $.extend(true, subformConfig, subformConfigurations[$(subformDiv).attr('subform-config-object')])
            }

            // Override the specified config object if any extra typeahead attributes were set
            if(!_.isEmpty($(subformDiv).attr('subform-modal'))) subformConfig['subformModal'] = true
            if(!_.isEmpty($(subformDiv).attr('subform-slug'))) subformConfig['subformSlug'] = $(subformDiv).attr('subform-slug')
            if(!_.isEmpty($(subformDiv).attr('subform-empty-message'))) subformConfig['emptyMessage'] = $(subformDiv).attr('subform-empty-message')
            
            // Generate Unique ID for Table / Modal
            subformConfig['subformId'] = Date.now();

            // Check to see if the subform-columns attribute was provided and override the config object provided
            if(!_.isEmpty($(subformDiv).attr('subform-columns'))){
              subformConfig['columns'] = []
              $.each($(subformDiv).attr('subform-columns').split(','), function(i, v){
                  var name = v.split('=')[0]
                  var field = v.split('=')[1]
                  subformConfig['columns'].push( { 'name':name,'data':field,'title':name } );
              })
            }

            // If no columns were provided by the config object, or element attributes, retrieve the subform's fields
            // and use them as columns
            if(_.isEmpty(subformConfig['columns'])){
              getSubFormColumns(function(result){
                if(result !== "ERROR"){
                  columns = [];
                  $.each(result.form.pages,function(pageNum,page){
                    $.each(page.elements,function(elementNum,element){
                      if(element.visible === true){
                        findFields(element);
                      }
                    })
                  })
                  subformConfig['columns'] = columns;
                } else {
                  alert('Error retrieving subform fields. Contact your system administrator.');
                }
              })
              // Given a form element, find visible fields
              // Recursively called to find all visible fields in all visible sections
              function findFields(element){
                if(element.type === 'field' && element.visible === true){
                    columns.push({'name':element.name,'data':element.name,'title':element.label})
                } else if (!_.isEmpty(element['elements'])) {
                  $.each(element['elements'],function(childNum,child){
                    if(child.visible === true){
                      findFields(child);
                    }
                  })
                }
              }
              // Does ajax call to get the subform's definition
              function getSubFormColumns(callback){
                $.ajax({
                  url: bundle.apiLocation() + '/kapps/' + bundle.kappSlug() + '/forms/' + subformConfig['subformSlug'] + '?include=pages',
                  async: false,
                  success: function(form){
                    // If form was retrieved, return it
                    callback(form)    
                  },
                  error: function(jqXHR, textStatus, errorThrown){
                    callback("ERROR")
                  },
                  dataType: 'json'
                });
              }
            }

            // Make sure each column has a title and name
            $.each(subformConfig['columns'],function(i,column){
              if(_.isEmpty(column['title'])){
                column['title'] = column['name'];
              }
            })

            // Add Id Column (will store the subform submission id in table)
            subformConfig['columns'].push(
              { title: 'Id',
                data: 'Id',
                sortable: false,
                visible: false
              },
              { data: null,
                sortable: false,
                width: "80px",
                defaultContent: "<button class='btn-sm btn-primary' value='Edit'><i class='fa fa-pencil-square-o'></i></button> <button class='btn-sm btn-primary' value='Delete'><i class='fa fa-trash'></i></button>"
              }
            )
            if(subformConfig['subformChildSource'].toLowerCase() === 'ajax'){
              subformConfig['ajaxUrl'] = buildAjaxUrl();
            }
            //@@@ TOOOOO DDOOOOO @@@//
            // Move the buildAjaxUrl function to location in the file that is utility or just make it anonymous and executed immediately
            /* This fucntion builds a Url to be used by the ajax call.
             * The intention is to pass parameters to this function to make the url configurable.  This gives 
             * the ability to use the same piece of code to configure multiple queries.*/
            function buildAjaxUrl(){
                var url = bundle.apiLocation()+'/kapps/'+bundle.kappSlug()+'/forms/'+ subformConfig['subformSlug'] + '/submissions?include=details,values&timeline=createdAt&direction=DESC';
                if(subformConfig.coreState !== undefined){
                    url += '&coreState='+subformConfig.coreState; 
                } else {
                    url += '&coreState=Draft'
                }
                url += '&q=createdBy="' + K('identity').username + '"'
                if(subformConfig.parentId !== undefined){
                    url += ' AND values[Parent Id] = "' + subformConfig.parentId + '"';
                }
                return url;
            };

            //@@@ TOOOOO DDOOOOO @@@//
            // Determine and build bridge url to use
            if(subformConfig['subformChildSource'].toLowerCase() === 'bridge'){
              if(!_.isEmpty(subformConfig['bridgeLocation'])){
                  subformConfig['bridgeUrl'] = bundle.kappLocation() + "/" + subformConfig['bridgeLocation'] + "/bridgedResources/" + subformConfig['bridgedResource'] + "?values[" + subformConfig['queryField'] + "]=%QUERY"
              } else {
                  subformConfig['bridgeUrl'] = bundle.kappLocation() + "/" + K('form').slug() + "/bridgedResources/" + subformConfig['bridgedResource']  + "?values[" + subformConfig['queryField'] + "]=%QUERY"
              }
            }

            //@@@ TOOOOO DDOOOOO @@@//
            // Add Error Checking to make sure we have all of the fields we need.

            // Stop processing if no fields or bridgedresource have been defined 
            // if( Object.keys(subformConfig['fieldsToSet']).length < 1 || _.isEmpty(subformConfig['bridgedResource']) 
            //     || _.isEmpty(subformConfig['bridgeUrl']) || _.isEmpty(subformConfig['attrToSet']) ) {
            //     console.log("Typeahead Search Misconfigured");
            //     return false;
            // }

            // Manipulate DOM to prepare for Typeahead Searching
            $(subformDiv).append($('<table data-subform="' + subformConfig['subformId'] + '" class="display table table-striped table-hover responsive no-wrap" width="100%"></table>'))
            if(subformConfig['addRecordButton'] !== false){
                $(subformDiv).append($('<div/>').append('<button data-subform="' + subformConfig['subformId'] + '" class="btn btn-default">Add Record</button>'))
            }
            // Build and populate Subform's Container - either modal or in-parent
            if(subformConfig['subformModal']){
              var modal = $('<div class="modal fade" data-subform="' + subformConfig['subformId'] + '"/>').append(
              $('<div class="modal-dialog modal-lg"/>').append(
                $('<div class="modal-content"/>').append(
                  $('<div class="modal-body"/>').append(
                    $('<i class="fa fa-cog fa-spin"/>')))));
              $('body').append(modal);
              subformConfig['subformContainer'] =  'div[data-subform="' + subformConfig['subformId'] + '"] .modal-body'
            } else {
              var subForm = $('<div data-subform="' + subformConfig['subformId'] + '"/>').append('<div class="subform-body"</div>')
              $(subformDiv).append(subForm);
              subformConfig['subformContainer'] =  'div[data-subform="' + subformConfig['subformId'] + '"] .subform-body'
            }

            // Build Search Function that will be passed to the datatable. Either ajax or bridged
            var ajaxFunction;
            if(subformConfig['subformChildSource'].toLowerCase() === 'ajax'){
                ajaxFunction =  {
                  url: subformConfig['ajaxUrl'],
                  dataSrc: function ( data ) {
                    var subformSubmissions = [];
                    $.each(data.submissions, function(index, submission){
                      subformSubmission = submission.values
                      subformSubmission['Id'] = submission.id;
                      subformSubmissions.push(submission.values)
                    });
                    return subformSubmissions;
                  }
                }
            } else if (subformConfig['subformChildSource'].toLowerCase() === 'bridge'){
                // NEED TO BUILD THE BRIDGE SUBMISSIONS HANDLING HERE
                
            }
            // Build Datatable
            var oTable = $(subformDiv).find('table[data-subform="' + subformConfig['subformId'] + '"]').DataTable({
              dom: 'T',
              responsive: true,
              columns: subformConfig['columns'],
              language: {
                zeroRecords: subformConfig['emptyMessage']
              },
              ajax: ajaxFunction,
              fnRowCallback: function(){console.log('hi')}
            });
            // Add Click Event on Add Record Button
            $(subformDiv).find('button[data-subform="' + subformConfig['subformId'] + '"]').click(function(){
              subformTables.launch(oTable, null, null, subformConfig);
            });

            //Attach listeners here for when a row is clicked:
            $('table[data-subform="' + subformConfig['subformId'] + '"]').on("click","tr td button",function() {
              var row = $(this).closest('tr'),
                  index = oTable.row(row).index(),
                  rowData = oTable.row(index).data();
                  
              if ($(this).val() == "Edit") {
                $(subformConfig['subformContainer']).empty().html($('<div class="text-center">').append($('<i class="fa fa-cog fa-spin fa-5x"></i>')));
                subformTables.launch(oTable, row, rowData, subformConfig);
              }
              
              if ($(this).val() == "Delete") {
                var myConfirmation = confirm('Are you sure you want to delete this event type?')
                if (myConfirmation) {
                  $.ajax({
                    method: 'DELETE',
                    url: bundle.apiLocation() + '/submissions/' + rowData['Id'],
                    dataType: "json",
                    data:   null,
                    contentType: "application/json",
                    
                    // If form creation was successful run this code
                    success: function(response, textStatus, jqXHR){
                      oTable.row(row).remove().draw();
                    },
                    // If there was an error, show the error
                    error: function(jqXHR, textStatus, errorThrown){
                      //$('#newObject .modal-body #message').html('There was an error creating the Object ' + data.errorThrown);
                      console.log('There was an error removing the object: ' + errorThrown);
                    }
                  });
                }
              }
            })
        });
    }// End Subform function

    subformTables.launch = function(table, row, rowData, subformConfig){
      //Ensure subform container is empty
      $(subformConfig['subformContainer']).html($('<div class="text-center">').append($('<i class="fa fa-cog fa-spin fa-5x"></i>')));
      $(subformConfig['subformContainer']).parent().show();
      //Determing if we are opening an existing or new application configuration
      var path = bundle.kappLocation() + '/' + subformConfig['subformSlug'];
      if (row !== null) {
        path = bundle.spaceLocation() + '/submissions/' + rowData['Id'];
      }
      
      //Retrive and display the subform (in our case, in the modal)
      K.load({
        path:path,
        container: subformConfig['subformContainer'],
        loaded: function(form) { 
          subformConfig.subformLoadedCallback(table, row, rowData, subformConfig, form)    
        },
        created: function(submission) {
          subformConfig.subformCreatedCallback(table, row, rowData, subformConfig, submission) 
        },
        updated: function(submission) {
          subformConfig.subformUpdatedCallback(table, row, rowData, subformConfig, submission) 
        }
      }); 
    }
    // Function used to Build up Datatatble Row Data for Updates and Creates
    subformTables.buildRowData = function(subformConfig, submission){
      // Build RowData Object
      var rowData = {}
      $.each(subformConfig['columns'],function(i,v){
        if(v.data !== ""){
          rowData[v.data] = submission['submission']['values'][v.data];
        }
      })
      // Add Child Id
      rowData['Id'] = submission['submission']['id'];
      // Return Row Data
      return rowData;
    }
    
})(jQuery, _, moment);


// CONFIGURATION Object
subformConfigurations = {
    defaultConfiguration:{
        subformModal: false,  // Subform to be displayed in a modal (yes or no)
        subformSlug: null,  // Slug of the Subform to Load
        subformContainer: null,
        emptyMessage: 'No results found', // Message to display if no results are found
        columns: null, // array of Column Name to Subform Field Object Mappings
        subformChildSource: 'ajax',
        ajaxUrl: null,
        bridgedUrl: null,
        bridgedResource: null, // Name of Bridged Resource to Use - must match a valid bridge resource on the current or shared-resource form
        bridgeLocation: null, // If the search uses a shared-resource form specify it's slug - Defaults to current form
        subformLoadedCallback: function(table, row, rowData, subformConfig, form) {    
          if(subformConfig['subformModal']) { 
            //Display the modal
            $(subformConfig['subformContainer']).parents('.modal').modal('show');
          } else {
            $(subformConfig['subformContainer']).show();
            $(subformConfig['subformContainer']).show();
          }
          // Hide the Submit Button on the Subform if one exists (don't want to submit subform, only save)
          $(form.element()).find('button[data-button-type="submit-page"]').css('display','none'); 
        },
        subformCreatedCallback: function(table, row, rowData, subformConfig, submission) { 
          if(submission['submission']['values'] !== undefined) {
            rowData = subformTables.buildRowData(subformConfig, submission);
            // Create Datatable Row
            table.row.add(rowData).draw(true);
          }
          if(subformConfig['subformModal']) { 
            // Hide the Modal
            $(subformConfig['subformContainer']).empty();
            $(subformConfig['subformContainer']).parents('.modal').modal('hide'); 
          } else {
            $(subformConfig['subformContainer']).parent().hide()
          }
        },
        subformUpdatedCallback: function(table, row, rowData, subformConfig, submission) {
          if(submission['submission']['values'] !== undefined) {
            rowData = subformTables.buildRowData(subformConfig, submission);
            // Update Datatable Row
            table.row(row).data(rowData).draw(true);
          }
          if(subformConfig['subformModal']) { 
            // Hide the Modal
            $(subformConfig['subformContainer']).empty();
            $(subformConfig['subformContainer']).parents('.modal').modal('hide');
          } else {
            $(subformConfig['subformContainer']).parent().hide()
          }
        }
    }
};