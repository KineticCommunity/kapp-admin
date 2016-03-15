
$(function() {    
    // Make list sortable
    $( ".sortable" ).sortable({
        connectWith: ".sortable",
        items: "li",
        cursor: "move",
        forceHelperSize: true,
        scroll: true,
        tolerance: "intersect",
        dropOnEmpty: true,
        placeholder: "ui-sortable-placeholder",
        receive: function( event, ui ) {
            var kapp = $('ul.kapp-select li.active').attr('data-slug');
            if(lastUpdated != undefined && lastUpdated.length == 0){
                lastUpdated = $(ui.item).attr('name');
                updateCategory(kapp,ui.item);
            }
        },
        update: function( event, ui ) {
            var kapp = $('ul.kapp-select li.active').attr('data-slug');
            if(lastUpdated != undefined && lastUpdated.length == 0){
                lastUpdated = $(ui.item).attr('name');
                updateCategory(kapp,ui.item);
            }
        }
    }).disableSelection();


    // Add click event to add categories
    $('i.add-root').on('click', function(){
        //toggle plus minus
        $(this).toggleClass('fa-plus fa-minus');
        if($('div.add-root').is(":visible")){
            $('div.add-root').slideUp('slow')
        }
        else{
            $('div.add-root').insertAfter($(this)).slideDown('slow');
        }
    });

    // Add click event to edit category
    $('i.edit').on('click', function(){
        $(this).toggleClass('fa-pencil fa-close');
        if($(this).hasClass('fa-close')){
            // Add the update form into the li
            $('div.change-form').insertAfter($(this).parent());
        } else {
            $('div.change-form').appendTo('div.change-name');
        }
    });

    // Add click event to submit edit
    $('button#update-category').on('click', function(){
        // Get the kapp name
        var kapp = $('ul.kapp-select li.active').attr('data-slug'), name = $('#change-name').val(), displayName = $('#change-display').val(), originalCat = $(this).closest('li').attr('data-id');
        // Check for special characters in name
        if(/^[a-zA-Z0-9- ]*$/.test(name) == false) {
            alert('Your search string contains illegal characters.');
            return false;
        }
        // check if category already exists
        if($(this).closest('li').attr('data-id') != name && $('li[data-id="' + name + '"]').length > 0){
            alert('A catagory with that name already exists.');
            return false;
        }
        // Update the li
        var li = $(this).closest('li').attr({
            "data-id": name,
            "data-display":displayName
        });
        // Update the display
        $(this).parent().siblings('strong').text(displayName != '' ? displayName : name).append(" ").append( 
                    $('<i>').addClass('fa fa-pencil edit').on('click', function(){
                        $(this).toggleClass('fa-pencil fa-close');
                        if($(this).hasClass('fa-close')){
                            // Add the update form into the li
                            $('div.change-form').insertAfter($(this).parent());
                        } else {
                            $('div.change-form').appendTo('div.change-name');
                        }
                    })
                );
        updateCategory(kapp,li,undefined,undefined,originalCat);
        // Empty out the form fields
        $('#change-name').val(''); 
        $('#change-display').val('');
        // Move form back to hidden div
        $(this).closest('div').appendTo('div.change-name');
    });

    // Add button event to add root cats
    $('div.add-root button').on('click', function(){
        var kapp = $('ul.kapp-select li.active').attr('data-slug'), name = $('#category-name').val(), displayName = $('#display-name').val();
        // Check for special characters in name
        if(/^[a-zA-Z0-9- ]*$/.test(name) == false) {
            alert('Your search string contains illegal characters.');
            return false;
        }
        // check if category already exists
        if( $('li[data-id="' + name + '"]').length > 0){
            alert('A catagory with that name already exists.');
            return false;
        }
        // If it's new create the category
        createCategory(kapp,name,displayName);
        // Update display
        $('div.workarea ul.top').append(
            $('<li>').attr('data-id',name).append(
                $('<strong>').text(displayName != '' ? displayName : name).append(
                    $('<i>').addClass('fa fa-pencil')
                ),
                $('<ul>').addClass('subcategories sortable')
            )
        );
        if(displayName.length > 0){
            $('li[data-id="'+name+'"]').attr('data-display',displayName);
        }
    });

 });

// Global variable to check so we don't send the same api call multiple times
var lastUpdated = '';

// Create a new category with api call
function createCategory(kapp, categoryName, displayName, sortOrder, parent) {
    // URL for api
    var url = bundle.spaceLocation() + '/app/api/v1/kapps/' + kapp + '/categories', payload;
    // Check for display name if so, add attributes
    if(displayName.length > 0){
        payload = '{"attributes": [{ "name":"Display Name","values":["' + displayName + '"]}], "name": "' + categoryName + '"}';
        url = url + '?include=attributes';
    }
    else {
        payload = '{"name": "' + categoryName + '"}';
    }

    $.ajax({
        method: 'POST',
        url: url,
        dataType: "json",
        data: payload,
        contentType: "application/json",
        error: function(jqXHR){

        }
    });
}

// Update a current category
function updateCategory(kapp,obj,siblings,stopSiblings, originalCategory) {
    var category, categoryName = $(obj).attr('data-id');
    // Check if originalCategory is defined. This will contain the 
    // category name to update because we can update the category name.
    originalCategory != undefined ? category = originalCategory : category = categoryName;
    // If only the display name is updated, we have an empty categoryName so set
    // to the original name
    if(categoryName == undefined) { categoryName = category; }
    // If they are both empty - we need to quit
    if(categoryName == undefined && category == undefined){
        return false;
    }
    var sortOrder = $(obj).index();
    var displayName = $(obj).attr('data-display');
    var parent = $(obj).parent().closest('li').attr('data-id');
    var url = bundle.spaceLocation() + '/app/api/v1/kapps/' + kapp + '/categories/' + category + '?include=attributes';

    // Create the payload by what is defined
    var payload = '{"name": "' + categoryName + '",';
    // These are attributes 
    if( sortOrder != undefined || displayName != undefined || parent != undefined){
        payload = payload + '"attributes": [';
        if(displayName != undefined){
            payload = payload + '{ "name":"Display Name","values":["' + displayName + '"]},';
        }
        if(sortOrder != undefined){
            payload = payload + '{ "name":"Sort Order","values":["' + sortOrder + '"]},';
        }   
        if(parent != undefined){
            payload = payload + '{ "name":"Parent","values":["' + parent + '"]},';
        }
        payload = payload.substring(0,payload.length-1) + '] '; 
    }
    // Close the payload
    payload = payload + '}';
    // Update via api
    $.ajax({
        method: 'PUT',
        url: url,
        dataType: "json",
        data: payload,
        contentType: "application/json"
    }).done(function(){
        // clear our the lastUpdated
        lastUpdated = '';
        // Check if we need to skip siblings
        if(!stopSiblings){
            // Update siblings to correct duplicate sort numbers
            if(siblings != undefined){
                var stop = false;
                var item = siblings[0];
                if(siblings.length === 1) {stop = true;}
                siblings.splice(0,1);
                updateCategory(kapp,$(item),siblings,stop);
            }
            else {
                var item = $(obj).siblings()[0];
                $(obj).siblings().splice(0,1);
                updateCategory(kapp,$(item),$(obj).siblings());
            }
        }
    });
}