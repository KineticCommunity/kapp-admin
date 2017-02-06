  var textElData,
      kappDetails,
      formDetails;

  
// Ensure the BUNDLE global object exists
bundle = typeof bundle !== "undefined" ? bundle : {};
// Create namespace for Admin Notification Console
bundle.adminNotifications = bundle.adminNotifications || {};
bundle.adminNotifications.templates = bundle.adminNotifications.templates || {};
// Your method
bundle.adminNotifications.templates.init = function(){
    //populate the kappsDynamicMenu - Bridge not used to not clutter up the bridge list with 'internal use' functions.
    bundle.adminNotifications.templates.getSpaceAttributes();
    bundle.adminNotifications.templates.getAllKapps();
    bundle.adminNotifications.templates.getDateFormats();
    bundle.adminNotifications.templates.rebindClickEventToSelectionMenu();
    
    //Bind event to the textarea elements on the page (Subject, Message Body, and Text Message Body)
    //May want to add a class or custom data attribute to these to make this more selective in the event other elements ever get added.
    $('textarea[data-allows-replacement]').on("focusout", function(e) {
      //e.preventDefault();
      textElData = {
        "id":$(this).attr('id'),
        "startingPosition":$(this).prop('selectionStart'),
        "endingPosition":$(this).prop('selectionEnd'),
		"ckeditor":"false"
       };
    })
    //Bind an event to all text area and input nodes to clear the textElData variable, otherwise inadvertent replacement can be inserted.
    $('textarea:not([data-allows-replacement]), input').on("focusout", function() {
      textElData = null;
    })
	


    //Bind an event to replacement button to hide the appearance warning message
    $('#dynamicDropdownMenu').on('click',function() {
      $('.appearance-alert').fadeOut();
    })
	
	//RTF for template
	if (K('form').slug() == "notification-templates")  {
		bundle.adminNotifications.templates.rtfBody = CKEDITOR.replace( 'Message Body', {  customConfig: '../../js/notifications/notifications_ckeditor.js'} );
	} else {
	//RTF for snippet
		bundle.adminNotifications.templates.rtfBody = CKEDITOR.replace( 'HTML Content', { customConfig: '../../js/notifications/notifications_ckeditor.js' } );
	}
	//bind event for Rich Text Editor to allow variables to be inserted
	bundle.adminNotifications.templates.rtfBody.on("blur", function(e) {
      //e.preventDefault();
      textElData = {
        "id":$(this).attr('id'),
        "ckeditor":"true"
       };
    })
  }
  
bundle.adminNotifications.templates.getSpaceAttributes = function(){
    K.api("GET",bundle.spaceLocation() + "/app/api/v1/space?include=attributes",{"complete":function(data){bundle.adminNotifications.templates.populateSpaceAttributes(data)}})
  }
  
bundle.adminNotifications.templates.getAllKapps = function(){
    K.api("GET",bundle.spaceLocation() + "/app/api/v1/kapps?include=attributes",{"complete":function(data){bundle.adminNotifications.templates.populateKappList(data)}})
  }
  
bundle.adminNotifications.templates.getDateFormats = function(){
    K.api("GET",bundle.spaceLocation() + "/app/api/v1/kapps/" + bundle.kappSlug() + "/forms/notification-template-dates/submissions?include=details,values&limit=999&q=values[Status]=\"active\"",{"complete":function(data){bundle.adminNotifications.templates.populateAppearanceOptions(data)}})
  }

bundle.adminNotifications.templates.getAllKappForms = function(kappSlug) {
    K.api("GET",bundle.spaceLocation() + "/app/api/v1/kapps/" + kappSlug + "/forms?include=attributes,fields",{"complete":function(data){bundle.adminNotifications.templates.populateFormList(data)}})
  }

bundle.adminNotifications.templates.populateSpaceAttributes = function(data){
    var spaceAttributes = JSON.parse(data["responseText"])["space"]["attributes"];
    $('ul.dropdown-menu[data-menu-name="Space Attributes"]').empty();
    $.each(spaceAttributes,function(iterator,value) {
      $('ul.dropdown-menu[data-menu-name="Space Attributes"]').append('<li><a class="dynamic-replacement" tabindex="-1" href="#">spaceAttributes(\'' + value['name'] + '\')</a></li>')
    })
    bundle.adminNotifications.templates.rebindClickEventToSelectionMenu();
  }

bundle.adminNotifications.templates.populateAppearanceOptions = function(data){
    var dateSubmissions = JSON.parse(data["responseText"])['submissions'];
    $('ul.dropdown-menu[data-menu-name="Appearance Attributes"]').empty();
    if (dateSubmissions.length > 0) {
      $.each(dateSubmissions,function(iterator,value) {
        $('ul.dropdown-menu[data-menu-name="Appearance Attributes"]').append('<li><a class="dynamic-replacement dynamic-appearance" tabindex="-1" href="#">appearance(\':: date field here ::${format(\'' + value['values']['Name'] + '\')}\')</a></li>');
      })
      $('ul.dropdown-menu[data-menu-name="Appearance Attributes"]').append('<li class="disabled"><a class="dynamic-replacement-noaction" href="#">Enter additional formats in the Datastore form <button id="notification-dates-button" data-element-type="button" data-button-type="custom" class="btn btn-link">Notification Dates</button> </a></li>');
      $('ul.dropdown-menu a.dynamic-replacement-noaction').on('click',function(e) {
        e.preventDefault();
      })
    } else {
      $('ul.dropdown-menu[data-menu-name="Appearance Attributes"]').append('<li class="disabled"><a class="dynamic-replacement-noaction" href="#">No Date Format have been defined.<br>Enter formats in the Datastore form <button id="notification-dates-button" data-element-type="button" data-button-type="custom" class="btn btn-link">Notification Dates</button> </a></li>');
      $('ul.dropdown-menu a.dynamic-replacement-noaction').on('click',function(e) {
        e.preventDefault();
      })
    }
    $('#notification-dates-button').on('click',function(e) {
        window.open(bundle.spaceLocation() + '/' + bundle.kappSlug() + '/datastore?kapp=admin&page=datastore/store&store=notification-template-dates', '_blank');
      })
    //bind event to newly added items
    bundle.adminNotifications.templates.rebindClickEventToSelectionMenu();
  }

bundle.adminNotifications.templates.populateKappList = function(data){
    kappDetails = JSON.parse(data["responseText"]);
    var kappArray = kappDetails["kapps"];
    $('#kappSelectionList').append("<option></option>");
    $.each(kappArray,function(i,val) {
      $('#kappSelectionList').append("<option value='" + val["slug"] + "'>" + val["name"] + "</option>");
    })
    $('#kappSelectionList').change(function() {
      var selectedKapp = $(this).val();
      if ($(this).val() != null && $(this).val() != "" ) {
        bundle.adminNotifications.templates.getAllKappForms($(this).val());
        //Populate KAPP attributes
        $.each(kappDetails["kapps"],function(i,val) {
          if (val["slug"] === selectedKapp) {
            //find proper dropdown menu, then empty and repopulate
            $('ul.dropdown-menu[data-menu-name="Kapp Attributes"]').empty();
            $.each(val["attributes"],function(iterator,value) {
              $('ul.dropdown-menu[data-menu-name="Kapp Attributes"]').append('<li><a class="dynamic-replacement" tabindex="-1" href="#">kappAttributes(\'' + value['name'] + '\')</a></li>')
            })
            //bind event to newly added items
            bundle.adminNotifications.templates.rebindClickEventToSelectionMenu();
          }
        })
      } else {
        $('#kappFormSelectionList').val("");
        $('#kappFormSelectionList').empty();
        $('ul.dropdown-menu[data-menu-name="Kapp Attributes"]').empty();
        $('ul.dropdown-menu[data-menu-name="Kapp Attributes"]').append('<li><a class="dynamic-replacement" tabindex="-1" href="#">kappAttributes(\'Replace with attribute name\')</a></li>');
        $('ul.dropdown-menu[data-menu-name="Form Attributes"]').empty();
        $('ul.dropdown-menu[data-menu-name="Form Attributes"]').append('<li><a class="dynamic-replacement" tabindex="-1" href="#">formAttributes(\'Replace with attribute name\')</a></li>');
        $('ul.dropdown-menu[data-menu-name="Submission Values"]').empty();
        $('ul.dropdown-menu[data-menu-name="Submission Values"]').append('<li><a class="dynamic-replacement" tabindex="-1" href="#">values(\'Replace with form field name\')</a></li>');
        //bind event to newly added items
        bundle.adminNotifications.templates.rebindClickEventToSelectionMenu();
      }
    })
  }

bundle.adminNotifications.templates.populateFormList = function(data){
    formDetails = JSON.parse(data["responseText"]);
    var formArray = formDetails["forms"];
    $('#kappFormSelectionList').empty();
    $('#kappFormSelectionList').append("<option></option>");
    $.each(formArray,function(i,val) {
      $('#kappFormSelectionList').append("<option value='" + val["slug"] + "'>" + val["name"] + "</option>");
    })
  
    $('#kappFormSelectionList').change(function() {
      var selectedForm = $(this).val();
      if ($(this).val() != null && $(this).val() != "" ) {
        $.each(formDetails["forms"],function(i,val) {
          if (val["slug"] === selectedForm) {
            //find proper dropdown menu for form attributes, then empty and repopulate
            $('ul.dropdown-menu[data-menu-name="Form Attributes"]').empty();
            $.each(val["attributes"],function(iterator,value) {
              $('ul.dropdown-menu[data-menu-name="Form Attributes"]').append('<li><a class="dynamic-replacement" tabindex="-1" href="#">formAttributes(\'' + value['name'] + '\')</a></li>')
            })
            //bind event to newly added items
            bundle.adminNotifications.templates.rebindClickEventToSelectionMenu();

            //find proper dropdown menu for submission attributes, then empty and repopulate
            $('ul.dropdown-menu[data-menu-name="Submission Values"]').empty();
            $.each(val["fields"],function(iterator,value) {
              //What to do with the second ones--they should not have the tabindex=-1 thing....
              $('ul.dropdown-menu[data-menu-name="Submission Values"]').append('<li><a class="dynamic-replacement" tabindex="-1" href="#">values(\'' + value['name'] + '\')</a></li>')
            })
            //bind event to newly added items
            bundle.adminNotifications.templates.rebindClickEventToSelectionMenu();
          }
        })
      } else {
        $('ul.dropdown-menu[data-menu-name="Form Attributes"]').empty();
        $('ul.dropdown-menu[data-menu-name="Form Attributes"]').append('<li><a class="dynamic-replacement" tabindex="-1" href="#">formAttributes(\'Replace with attribute name\')</a></li>');
        $('ul.dropdown-menu[data-menu-name="Submission Values"]').empty();
        $('ul.dropdown-menu[data-menu-name="Submission Values"]').append('<li><a class="dynamic-replacement" tabindex="-1" href="#">values(\'Replace with form field name\')</a></li>');
        bundle.adminNotifications.templates.rebindClickEventToSelectionMenu();
      }
    })
  }
  
bundle.adminNotifications.templates.insertTextAtCaret = function(elPosition,replacementText) {
    if (typeof elPosition != 'undefined' && elPosition != null) {
      replacementText = "${" + replacementText + "}";
      var v = $('#' + elPosition["id"]).val();
	  if (elPosition["ckeditor"] == "false") {
		  var textBefore = v.substring(0,  elPosition["startingPosition"] );
		  var textAfter  = v.substring( elPosition["endingPosition"], v.length );
		  var newCursorPos = elPosition["startingPosition"] + replacementText.length;
		  if (replacementText.indexOf("appearance") < 0 ){
			$('#' + elPosition["id"]).val( textBefore + replacementText + textAfter );
		  } else {
			var textInbetween = v.substring(elPosition["startingPosition"],elPosition["endingPosition"])
			//Warn if selected data doesn't start with dollar sign and end with right curly brace
			if ((textInbetween.indexOf("$") != 0) || textInbetween.slice(-1) != "}"){
			  $('.appearance-alert-message').text("Be sure to select the entire replacement field before selecting an appearance option.  Ex: ${values('Requested Date')}");
			  $('.appearance-alert').fadeIn();
			  return;
			}
			var replacementParts = replacementText.split("::");
			$('#' + elPosition["id"]).val( textBefore + replacementParts[0] + textInbetween + replacementParts[2] + textAfter );
			newCursorPos = elPosition["startingPosition"] + replacementParts[0].length + textInbetween.length + replacementParts[2] + 6
		  }
		  var newCursorPos = elPosition["startingPosition"] + replacementText.length;
		  $('#' + elPosition["id"]).prop('selectionStart',newCursorPos)
		  $('#' + elPosition["id"]).prop('selectionEnd',newCursorPos)
		  $('#' + elPosition["id"]).focus();
	  }
	  else {
		bundle.adminNotifications.templates.rtfBody.insertText(replacementText);
	  }
	  
    }
  }
  
bundle.adminNotifications.templates.rebindClickEventToSelectionMenu = function() {
    //Bind event to the dynamic-replacement <a> in the dropdown list tags.
    $('ul.dropdown-menu a.dynamic-replacement').off("click");
    $('ul.dropdown-menu a.dynamic-replacement').on("click", function(e) {
      e.preventDefault();
      bundle.adminNotifications.templates.insertTextAtCaret(textElData,$(this).text());
    });
  }

