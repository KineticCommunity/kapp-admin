// Ensure the BUNDLE global object exists
bundle = typeof bundle !== "undefined" ? bundle : {};
// Create namespace for Admin Notification Console
bundle.adminNotifications = bundle.adminNotifications || {};
bundle.adminNotifications.details = bundle.adminNotifications.details || {};
// Your method
bundle.adminNotifications.details.init = function(){
  
  K('field[Notification Name]').value(bundle.adminNotifications.getUrlVars()["name"]);
  
  $('#NotificationName').html(K('field[Notification Name]').value());

KDSearch.executeSearch(messageConfigs.contentConfig);

}


  
messageConfigs = {
   contentConfig:{
    type: "BridgeDataTable",
        // responsive: OPTIONAL Default for "BridgeDataTable" is true but can be over written.
        responsive: true,
     "autoWidth":false,
        bridgeConfig:{
            resource: "Content",
            qualification_mapping: "Content By Notification",
            //Params to be created and passed to the Bridge.  VALUE MUST BE JQUERY SELECTOR.
            parameters: {'Notification Name': function(){ return K('field[Notification Name]').value();}},
        },
        processSingleResult: false,
        clearOnClick:false,
        // Properties in the data must match the attributes of the Bridge Request
        data: {
          "Status":{
            title:"Status",
            className: "all"
          },  
          "Language":{
            title:"Language",
            className: "all"
          },
          "Subject":{
            title:"Subject",
            className: "all"
          },
          "Body":{
            title:"Body",
            className: "all body"
          },
          "id":{
            title:"id",
            className: "never hidden"
            },
          "Empty":{
            title:" ",
            className: "all buttons",
            orderable:false
          },
        },
        //Where to append the table
        appendTo: function(){return $('#ContentListing');},
        // OPTIONAL: Create Table function or string to become jQuery obj
        resultsContainerId: 'currentContentTable',
        //After the Table has been created.
        before: function(){ //before search
                
        },
        error: function(){
        },
        //Define action to take place after SDR is complete.
        success: function (){
        },
        success_empty: function(){
        },
        complete: function(){
          $('#currentContentTable').addClass('table-hover').removeClass('table-striped table-bordered nowrap');
        },
        // Executes on click of element with class of select
        clickCallback: function(results){
        },
        createdRow: function ( row, data, index ) {
          //Since the content of these are likely to include tables
          //due to the complex nature of HTML emails, used a modified
          //selector to identify the proper td column.  This might 
          //need further modification in the future.

            //$('td',row).eq(6).addClass("cursorPointer").append(
            $('td.all.buttons',row).eq(0).addClass("cursorPointer").append(
              $('<div>').addClass("btn-group pull-right text-nowrap").append(
                $('<button>').attr({
                  title:"Edit Item",
                  value:"Edit",
                  style: "display:inline-block;float:none"
                }).addClass("btn btn-xs btn-default btn-edit").append(
                    $('<i>').addClass("fa fa-pencil fa-fw")
                  ).on('click',function(){
                    window.open(bundle.spaceLocation() +'/submissions/' + data["id"] +'?kapp=admin', "_blank");
                   
                }),
                $('<button>').attr({
                    title:"Delete Item",
                    value:"Delete",
                    style: "display:inline-block;float:none"
                  }).addClass("btn btn-xs btn-danger").append(
                    $('<i>').addClass("fa fa-close fa-fw")
                  ).on('click',function(){
                    $.ajax({
                      method: 'DELETE',
                      url: bundle.spaceLocation() + '/app/api/v1/submissions/' + data['id'],
                      dataType: "json",
                      data:   null,
                      contentType: "application/json",
                      
                      // If form creation was successful run this code
                      success: function(response, textStatus, jqXHR){
                          
                      },
                      // If there was an error, show the error
                      error: function(jqXHR, textStatus, errorThrown){
                          //$('#newObject .modal-body #message').html('There was an error creating the Object ' + data.errorThrown);
                          console.log('There was an error removing the object: ' + errorThrown);
                      }
                    });
                })
              )
            )
        },
        fnFooterCallback: function ( nRow, aaData, iStart, iEnd, aiDisplay ) {
        },
        dom: 'frtip',
   }
}