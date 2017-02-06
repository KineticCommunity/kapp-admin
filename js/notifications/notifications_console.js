// Ensure the BUNDLE global object exists
bundle = typeof bundle !== "undefined" ? bundle : {};
// Create namespace for Admin Notification Console
bundle.adminNotifications = bundle.adminNotifications || {};
bundle.adminNotifications.console = bundle.adminNotifications.console || {};
// Your method
bundle.adminNotifications.console.showSection = function(section){
 if (section == "Notifications") {
    if ($.fn.dataTable.isDataTable('#notificationTable')) {
	 $('#notificationTable').DataTable().destroy();
	}
   $('#Notifications').addClass('active');
   $('#Headers').removeClass('active');
   K('section[Notification Section]').show();
   K('section[Header and Footer Section]').hide();
   bundle.adminNotifications.console.getNotifications();
 } else {
    if ($.fn.dataTable.isDataTable('#headerFooterTable')) {
	 $('#headerFooterTable').DataTable().destroy();
	}
   $('#Headers').addClass('active');
   $('#Notifications').removeClass('active');
   K('section[Notification Section]').hide();
   K('section[Header and Footer Section]').show();
   KDSearch.executeSearch(searchConfigs.headerfooterConfig);
 }
}
  
bundle.adminNotifications.console.getNotifications = function() {
K('bridgedResource[Notifications]').load({
			attributes: "Notification Name", 
			values: {},
			success: function(response) {
				adtlConfig = {
				   messageConfig:{
				     JSON: bundle.adminNotifications.console.removeDuplicates(response)
				   }
				}
				KDSearch.executeSearch(searchConfigs.messageConfig,adtlConfig.messageConfig);
			}
	});
}

bundle.adminNotifications.console.removeDuplicates = function(arr) {
        newArr = new Array();
        for (i = 0; i < arr.length; i++) {
            if (!bundle.adminNotifications.console.duplValuescheck(newArr, arr[i]["Notification Name"])) {
                newArr.length += 1;
                newArr[newArr.length - 1] = arr[i];
            }
        }
        return newArr;
    }

bundle.adminNotifications.console.duplValuescheck = function(arr, e) {
        for (j = 0; j < arr.length; j++) if (arr[j]["Notification Name"] == e) return true;
        return false;
    }

searchConfigs = {
   messageConfig:{
		type: "JSONDataTable",
		responsive: false,
		processSingleResult: false,
		clearOnClick:false,
		searching:false,
		// Properties in the data must match the attributes of the Bridge Request
		data: {
			"Notification Name":{
				title:"Notification Name",
				className: "all"
			},
		},
		//Where to append the table
		appendTo: function(){return $('#NotificationListing');},
		// OPTIONAL: Create Table function or string to become jQuery obj
		//ID to give the table when creating it.
		resultsContainerId: 'notificationTable',
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
		  $('#notificationTable').addClass('table-hover').removeClass('table-striped table-bordered');
		},
		// Executes on click of element with class of select
		clickCallback: function(results){
		  //window.open(bundle.spaceLocation() +'/admin/notification-details?kapp=admin&name='+results['Notification Name'], "_blank");
		},
		createdRow: function ( row, data, index ) {
			$('td',row).eq(0).html('<a href="'+bundle.spaceLocation() +'/admin/notification-details?kapp=admin&name='+data['Notification Name']+'" target="_blank">'+data['Notification Name']+'</a>');
		},
		dom: 'frtip',
   },
  headerfooterConfig:{
		type: "BridgeDataTable",
		 bridgeConfig:{
            resource: "Headers and Footers",
            qualification_mapping: "Headers and Footers",
            //Params to be created and passed to the Bridge.  VALUE MUST BE JQUERY SELECTOR.
            parameters: {},
        },
		responsive: false,
		processSingleResult: false,
		clearOnClick:false,
		searching:false,
		// Properties in the data must match the attributes of the Bridge Request
		data: {
			"Name":{
				title:"Name",
				className: "all"
			},
			"Type":{
				title:"Type",
				className: "all"
			},
			"Status":{
				title:"Status",
				className: "all"
			},
			"Last Updated":{
				title:"Last Updated",
				className: "all",
				date: true,
				moment:"MMMM Do YYYY, h:mm:ss a"
			},
			"id":{
				title:"id",
				className: "never hidden"
			},
		},
		//Where to append the table
		appendTo: function(){return $('#HeaderFooter');},
		// OPTIONAL: Create Table function or string to become jQuery obj
		//ID to give the table when creating it.
		resultsContainerId: 'headerFooterTable',
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
		  $('#headerFooterTable').addClass('table-hover').removeClass('table-striped table-bordered');
		},
		// Executes on click of element with class of select
		clickCallback: function(results){
		  //window.open(bundle.spaceLocation() +'/submissions/'+results['id']+'?kapp=admin', "_blank");
		},
		createdRow: function ( row, data, index ) {
			$('td',row).eq(0).html('<a href="'+bundle.spaceLocation() +'/submissions/'+data['id']+'?kapp=admin" target="_blank">'+data['Name']+'</a>');
		},
		dom: 'frtip',
   },
}