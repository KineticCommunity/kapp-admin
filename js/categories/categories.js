$(function() {    

    /* Using jQuery ui sortable widget */
    $( ".sortable" ).sortable({
        connectWith: ".sortable",
        items: "li",
        cursor: "move",
        forceHelperSize: true,
        scroll: true,
        dropOnEmpty: true,
        placeholder: "ui-sortable-placeholder",
        receive: function( event, ui ) {
            // Get kapp slug
            var kapp = $('div.manage-categories').attr('data-slug');
            // The call can be made multiple times (receive and change) so check if we aren't already submitting a change
            if(lastUpdated != undefined && lastUpdated.length === 0){
                lastUpdated = $(ui.item).attr('name');
                updateCategory(kapp,ui.item);
            }
        },
        update: function( event, ui ) {
            // Get kapp slug
            var kapp = $('div.manage-categories').attr('data-slug');
            // The call can be made multiple times (receive and change) so check if we aren't already submitting a change
            if(lastUpdated != undefined && lastUpdated.length === 0){
                lastUpdated = $(ui.item).attr('name');
                updateCategory(kapp,ui.item);
            }
        }
    }).disableSelection();

    /* Add click event to edit category */
    $('div.category, div.category>div').on('click', function(){
        // hide all delete buttons
        $('button.delete').hide();
        // show this delete button
        $(this).find('button.delete').show();
        // Update edit form to hold the current values
        $('input#change-name').val($(this).parent().attr('data-id')); 
        $('input#change-display').val($(this).parent().attr('data-display'));
        // Show Edit form
        $('div[heading="Edit Category"]').show();
        // Close edit accordion
        if($('#edit-category').is(':visible')){
            // It's open so close it
            $('#edit-category').hide();
        }
        $('#edit-category').slideDown('fast');
        // Change title on Add Category to Add Sub Category
        $('div.panel-title.add-category').text('Add Subcategory');
        // Add parent
        $('input#parent-name').val($(this).parent().attr('data-id'));
    });

    /* Close edit if click outside the category */
    $(document).mouseup(function (event){
        var container = $("div.category, #accordion");
        if (!container.is(event.target) // if the target of the click isn't the container...
            && container.has(event.target).length === 0) // ... nor a descendant of the container
        {
            // Hide edit category form
            $('div[heading="Edit Category"]').hide();
            // hide all delete buttons
            $('button.delete').hide();
            // Change title to Add Category 
            $('div.panel-title.add-category').text('Add Category');
        }
    });

    /* Add click event to submit edit */
    $('button.edit-category').on('click', function(){
        event.preventDefault();
        // Get the kapp name
        var kapp = $('div.manage-categories').attr('data-slug'), name = $('#change-name').val(), displayName = $('#change-display').val(), originalCat = $('input#parent-name').val();
        // Check for special characters in name
        if(/^[a-zA-Z0-9- ]*$/.test(name) === false) {
            alert('Your search string contains illegal characters.');
            return false;
        }
        // check if category already exists
        if($('li[data-id="' + name + '"]').length > 0 && $('input#parent-name').val() !== name){
            alert('A catagory with that name already exists.');
            return false;
        }
        // Update the li
        var li = $('li[data-id="'+originalCat+'"]').attr({
            "data-id": name,
            "data-display":displayName
        });
        // Update the display
        $('li[data-id="'+name+'"] div.category').text(displayName !== '' ? displayName : name).append(" ").append( 
            $('<button>').addClass('btn btn-xs btn-danger delete pull-right').on('click', function(){
                deleteCategory(name);
            }).append(
                $('<i>').addClass('fa fa-inverse fa-close')
            )
        );
        // Update the category via API
        updateCategory(kapp,li,undefined,undefined,originalCat);
        // Move form back to hidden div
        $(this).closest('div').appendTo('div.change-name');
    });

    /* Add button event to add cats */
    $('button.add-category').on('click', function(event){
        event.preventDefault();
        var kapp = $('div.manage-categories').attr('data-slug'), name = $('#category-name').val(), displayName = $('#display-name').val(), parent = $('input#parent-name').val();
        // Check for special characters in name
        if(/^[a-zA-Z0-9- ]*$/.test(name) === false) {
            alert('Your search string contains illegal characters.');
            return false;
        }
        // check if category already exists and is not this item
        if( $('li[data-id="' + name + '"]').length > 0){
            alert('A catagory with that name already exists.');
            return false;
        }
        // Create the category
        createCategory(kapp,name,displayName,undefined, parent);
    });

 });

// Global variable to check so we don't send the same api call multiple times
var lastUpdated = '';

// Create a new category with api call
function createCategory(kapp, categoryName, displayName, sortOrder, parent) {
    // URL for api
    var url = bundle.spaceLocation() + '/app/api/v1/kapps/' + kapp + '/categories', payload;
    // Check for display name or parent if so, add attributes
    if(displayName.length > 0 || parent.length > 0){
        var attributes = "";
        if(displayName != undefined && displayName.length > 0) { 
            attributes = attributes + '{"name":"Display Name","values": ["' + displayName + '"]},';
        }
        if(parent != undefined && parent.length > 0) { 
            attributes = attributes + '{"name":"Parent","values": ["' + parent + '"]},';
        }

        payload = '{"attributes": [' + attributes.substring(0,attributes.length-1) + '], "name": "' + categoryName + '"}';
        url = url + '?include=attributes';
    }
    else {
        payload = '{"name": "' + categoryName + '"}';
    }
    // Ajax call to api
    $.ajax({
        method: 'POST',
        url: url,
        dataType: "json",
        data: payload,
        contentType: "application/json",
        success: function(){
            // Update display
            // hide all delete buttons
            $('button.delete').hide();
            // Build up category li
            var cat = $('<li>').attr({
                    'data-id':categoryName,
                    'display-name': displayName
                    }).append(
                        $('<div>').addClass('category').append(
                            $('<button>').addClass("btn btn-xs btn-danger delete pull-right").append(
                                $('<i>').addClass("fa fa-inverse fa-close")
                            )
                        ).prepend(displayName != '' ? displayName : categoryName)
                    );
            var subcatUl = $('<ul>').addClass('subcategories sortable')
            // Add new category to workspace
            // Is this a subcategory?
            if(parent.length > 0){
                $('li[data-id="'+parent+'"] ul').append(cat,subcatUl);
            }
            else {
                $('div.workarea ul.top').append(cat,subcatUl);
                cat.focus();
            }
            // Empty out the form fields
            $('#category-name').val(''); 
            $('#display-name').val('');
            $('#parent-name').val('');
            // Update the sort order and siblings
            var kapp = $('div.manage-categories').attr('data-slug');
            var li = $('li[data-id="'+categoryName+'"]');
            var siblings = li.siblings();
            updateCategory(kapp,li,siblings);
        },
        error: function(jqXHR){
            alert('There was an error creating the category.');
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
        // clear our the lastUpdated so we know we are done and can do the next
        lastUpdated = '';
        // Check if we need to skip siblings
        if(!stopSiblings){
            // Update siblings to correct duplicate sort numbers
            if(siblings != undefined){
                // We have a siblings array so set stop to false
                var stop = false;
                // Grab the first item which is the sibling we are going to update
                var item = siblings[0];
                // If this is the last sibling set the stop
                if(siblings.length === 1) {stop = true;}
                // Remove the sibling we are using
                siblings.splice(0,1);
                // Pass current sibling remaining siblings or stop if last one
                updateCategory(kapp,$(item),siblings,stop);
            }
            else {
                // We don't have siblings yet, so try for siblings
                var item = $(obj).siblings()[0];
                $(obj).siblings().splice(0,1);
                if(item != "undefined"){
                    updateCategory(kapp,$(item),$(obj).siblings());
                }
            }
        }
    });
    // Empty out the form fields
    $('#change-name').val(''); 
    $('#change-display').val('');
}