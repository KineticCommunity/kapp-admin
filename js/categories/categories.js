(function($, _) {
    /*----------------------------------------------------------------------------------------------
     * DOM MANIPULATION AND EVENT REGISTRATION
     *   This section is executed on page load to register events and otherwise manipulate the DOM.
     *--------------------------------------------------------------------------------------------*/  
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
            // Remove selected class from others
            $('div.category.selected').removeClass('selected');
            // Add selected class
            $(this).closest('div.category').addClass('selected');
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
                // Remove selected class
                $('div.category.selected').removeClass('selected');
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
                $('button.edit-category').notifie({ type: 'alert', severity: 'danger', message: 'Your search string contains illegal characters.' });
                return false;
            }
            // check if category already exists
            if($('li[data-id="' + name + '"]').length > 0 && $('input#parent-name').val() !== name){
                $('button.edit-category').notifie({ type: 'alert', severity: 'danger', message: 'A catagory with that name already exists.' });
                return false;
            }
            // Update the li
            var li = $('li[data-id="'+originalCat+'"]').attr({
                "data-id": name,
                "data-display":displayName
            });
            // Update the display
            $('div.category.selected').text(displayName !== '' ? displayName : name).append(" ").append( 
                $('<button>').addClass('btn btn-xs btn-danger delete pull-right').on('click', function(){
                    deleteCategory($('div.manage-categories').attr('data-slug'),name);
                }).append(
                    $('<i>').addClass('fa fa-inverse fa-close')
                )
            );
            // Update the category via API
            updateCategory(kapp,li,undefined,originalCat);
            // Move form back to hidden div
            $(this).closest('div').appendTo('div.change-name');
        });

        /* Add button event to add cats */
        $('button.add-category').on('click', function(event){
            event.preventDefault();
            var kapp = $('div.manage-categories').attr('data-slug'), name = $('#category-name').val(), displayName = $('#display-name').val(), parent = $('input#parent-name').val();
            // Check for special characters in name
            if(/^[a-zA-Z0-9- ]*$/.test(name) === false) {
                $('button.add-category').notifie({ type: 'alert', severity: 'danger', message: 'Your search string contains illegal characters.' });
                return false;
            }
            // check if category already exists and is not this item
            if( $('li[data-id="' + name + '"]').length > 0){
                $('button.add-category').notifie({ type: 'alert', severity: 'danger', message: 'A catagory with that name already exists.' });
                return false;
            }
            // Create the category
            createCategory(kapp,name,displayName,undefined, parent);
        });

        /* Add click event to submit edit */
        $('button.delete').on('click', function(event){
            event.stopImmediatePropagation();
            var name = $(this).closest('li').attr('data-id');
            deleteCategory($('div.manage-categories').attr('data-slug'),name);
        });

     });

    /*----------------------------------------------------------------------------------------------
     * COMMON FUNCTIONS
     *--------------------------------------------------------------------------------------------*/

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
                var cat = $('<li>').addClass('ui-sortable-handle').attr({
                        'data-id':categoryName,
                        'display-name': displayName
                        }).append(
                            $('<div>').addClass('category').append(
                                $('<button>').addClass("btn btn-xs btn-danger delete pull-right").append(
                                    $('<i>').addClass("fa fa-inverse fa-close")
                                )
                            ).prepend(displayName != '' ? displayName : categoryName),
                            $('<ul>').addClass('subcategories sortable ui-sortable')
                        );
                // Add new category to workspace
                // Is this a subcategory?
                if(parent.length > 0){
                    $('li[data-id="'+parent+'"]>ul').append(cat);
                }
                else {
                    $('div.workarea ul.top').append(cat);
                    cat.focus();
                }
                $('ul.sortable').sortable();
                // Empty out the form fields
                $('#category-name').val(''); 
                $('#display-name').val('');
                $('#parent-name').val('');
                // Update the sort order and siblings
                var kapp = $('div.manage-categories').attr('data-slug');
                var li = $('li[data-id="'+categoryName+'"]');
                updateCategory(kapp,li);
            },
            error: function(jqXHR){
                $('div.workarea').notifie({ type: 'alert', severity: 'danger', message: 'There was an error creating the category.' });
            }
        });
    }

    // Create siblings array
    var siblingsArray = [];
    // Update a current category
    function updateCategory(kapp,obj,stopSiblings, originalCategory) {
        if(siblingsArray.length === 0){
            siblingsArray = $(obj).siblings();
        }
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
            // Check if we shoudl update siblings
            if(!stopSiblings){
                // If this is the last sibling set the stop
                if(siblingsArray.length === 1) {stopSiblings = true;}
                var item = siblingsArray[0];
                siblingsArray.splice(0,1);
                updateCategory(kapp,$(item),stopSiblings);
            }
        });
        $('ul.sortable').sortable();
        // Empty out the form fields
        $('#change-name').val(''); 
        $('#change-display').val('');
    }

    // Create an array for storing all items to delete
    var deleleteArray = [];
    // Delete category
    function deleteCategory(kapp,categoryName,noConfirm) {
        if(deleleteArray.length === 0){
            deleleteArray = $('li[data-id="' + categoryName + '"]').find('li');
        }
        if(noConfirm){
            deleteCat(kapp,categoryName);
        }
        else {
            // Temp Confirm
            if(confirm('Do you want to delete this category? It will also delete all children.')){
                deleteCat(kapp,categoryName);
            }
            // Build the modal.
            /*modal = new KD.Modal({
                    header: '<h3>Confirm Delete</h3>',
                    body: 'Do you want to delete this category? It will also delete all children.',
                    footer: function(element, actions) {
                        element.append(
                            $('<button>').addClass('btn btn-success').text('OK').on('click',function(){
                                actions.accept(deleteCat(kapp,categoryName));
                            }),
                            $('<button>').addClass('btn btn-link').text('Dismiss').on('click',function(){
                                actions.dismiss();
                            })
                        );
                        console.log(element);
                    },
                    backdrop: true,
                    backdropclose: true,
                    keyboardclose: true,
                    renderCallback: false
                });
            modal.show();*/
        }

        function deleteCat(kapp,categoryName){
            payload = '{"name": "' + categoryName + '"}';
            // URL for api
            var url = bundle.spaceLocation() + '/app/api/v1/kapps/' + kapp + '/categories/' + categoryName, payload;
            // Update via api
            $.ajax({
                method: 'DELETE',
                url: url,
                dataType: "json",
                data: payload,
                contentType: "application/json"
            }).done(function(){
                $('li[data-id="' + categoryName + '"]').remove();
                // Delete children
                if(deleleteArray.length > 0){
                    deleteCategory(kapp,$(deleleteArray[0]).attr('data-id'),true);
                    deleleteArray.splice(0,1);
                }
            })
        }
    }

})(jQuery, _);



