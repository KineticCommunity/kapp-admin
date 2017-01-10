(function($, _) {
    /*----------------------------------------------------------------------------------------------
     * DOM MANIPULATION AND EVENT REGISTRATION
     *   This section is executed on page load to register events and otherwise manipulate the DOM.
     *--------------------------------------------------------------------------------------------*/  
    $(function() {    
        /*
         * Initialize DataTable for dom sourced tables
         */
        $("table[data-table-dom]").each(function(i,table){
            var pageLength = $(table).data("page-length") || 25;
            var dom = $(table).data("dom") 
                    || $(table).find("tbody tr").length > pageLength 
                        ? "<'dt-title'f>t<'pull-right'p>i"
                        : ($(table).find("tbody tr").length > 0
                            ? "<'dt-title'f>ti"
                            : "<'dt-title'>t");
            var options = {
                autoWidth: false,
                dom: dom,
                pageLength: pageLength,
                language: {
                    search: "Filter",
                    paginate: {
                        previous: "<",
                        next: ">"
                    }
                },
                drawCallback: function(){
                    $("[data-tooltip]").tooltip();
                }
            };
            if ($(table).data("empty-message")){
                options.language.emptyTable = $(table).data("empty-message");
            }
            $(table).dataTable(options);
            $(table).on("click", "td", function(e){
                if (e.target == this){
                    $(this).closest("tr").toggleClass("full-text");
                }
            });
            $(table).parent().find("div.dt-title").prepend($("<h4>", {class: "pull-left"}).append($(table).data("table-name")));
        });
        
        /* Create Attribute Definitions if they don't exist */
        // Get kapp name
        var kapp = $('div.manage-categories').attr('data-slug');
        // Grab attribute definitions
        $.ajax({
            method: 'GET',
            url: bundle.spaceLocation() + '/app/api/v1/kapps/' + kapp + '/categoryAttributeDefinitions',
            dataType: "json",
            contentType: "application/json",
            success: function( data ){
                // Create array to work against
                var attributes = ['Parent','Sort Order'];
                // Remove each item if the definition already exists
                $.each(data.categoryAttributeDefinitions,function(index,val){
                    attributes = jQuery.grep(attributes, function(value) {
                      return value != val.name;
                    });
                });
                // If we have items that means definitions are needed
                if(attributes.length > 0){
                    // Create definitions per attribute needed
                    createDefinition();
                    // self calling functions if there are attributes left
                    function createDefinition(){
                        // Grab first definition name
                        var definition = attributes[0];
                        // Remove it from the 
                        attributes.splice(0,1);
                        // Ajax call to api to add definition
                        $.ajax({
                            method: 'POST',
                            url: bundle.spaceLocation() + '/app/api/v1/kapps/' + kapp + '/categoryAttributeDefinitions',
                            dataType: "json",
                            data: '{"allowsMultiple": false,"name": "'+ definition +'"}',
                            contentType: "application/json",
                            success: function(){
                                // Are there more left?
                                if(attributes.length > 0){
                                    createDefinition();
                                }
                            },
                            error: function(jqXHR){
                                $('div.workarea').notifie({ type: 'alert', severity: 'danger', message: 'There was an error creating the attribute definition.', disable: false});
                            }
                        });
                    }
                }
            },
            error: function(){
                $('div.workarea').notifie({ type: 'alert', severity: 'danger', message: 'There was an error checking attribute definitions.', disable: false});
            }
        });
    
        /* Using jQuery ui sortable widget */
        $( ".sortable" ).sortable({
            connectWith: ".sortable",
            items: "li",
            cursor: "move",
            forceHelperSize: true,
            scroll: true,
            dropOnEmpty: true,
            handle: "div.category",
            cursor: "move",
            placeholder: "ui-sortable-placeholder",
            receive: function( event, ui ) {
                // Get kapp slug
                var kapp = $('div.manage-categories').attr('data-slug');
                // The call can be made multiple times (receive and change) so check if we aren't already submitting a change
                if(lastUpdated != undefined && lastUpdated.length === 0){
                    lastUpdated = $(ui.item).attr('name');
                    updateCategory(kapp,ui.item,undefined,undefined,false);
                }
            },
            update: function( event, ui ) {
                // Get kapp slug
                var kapp = $('div.manage-categories').attr('data-slug');
                // The call can be made multiple times (receive and change) so check if we aren't already submitting a change
                if(lastUpdated != undefined && lastUpdated.length === 0){
                    lastUpdated = $(ui.item).attr('name');
                    updateCategory(kapp,ui.item,undefined,undefined,false);
                }
            }
        }).disableSelection();

        /* Add click event to edit category */
        $('div.workarea').on('click', 'div.category:not(".selected"), div.category>div:not(".selected")', function(event){
            clearSelectedCategory();
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
            // Add parent
            $('input#parent-name').val($(this).parent().attr('data-id'));
        });

        /* Click event for subcategory */
        $('button.add-subcategory').on('click',function(){
            event.preventDefault();
            // Change title on Add Category to Add Sub Category
            $('div.panel-title.add-category').text('Add Subcategory');
            // Show Edit form
            $('div[heading="Add Category"]').show();
            // Close edit accordion
            if($('#add-category').is(':visible')){
                // It's open so close it
                $('#add-category').hide();
            }
            $('#add-category').slideDown('fast');
        })

        /* Close edit if click outside the category */
        $(document).mouseup(function (event){
            var container = $("div.category, #accordion, div.table.no-data");
            if (!container.is(event.target) // if the target of the click isn't the container...
                && container.has(event.target).length === 0) // ... nor a descendant of the container
            {
                clearSelectedCategory();
            }
        });

        /* Add click event to submit edit */
        $('button.edit-category').on('click', function(){
            $('div.workarea').notifie({ exit: true });
            $('button.add-category').notifie({ exit: true });
            event.preventDefault();
            // Get the kapp name
            var kapp = $('div.manage-categories').attr('data-slug'), name = $('#change-name').val(), displayName = $('#change-display').val(), originalCat = $('input#parent-name').val();
            // Check if both fields are empty
            if(name.length < 1 && displayName.length < 1) {
                $(this).notifie({ type: 'alert', severity: 'danger', message: 'Both fields cannot be empty.', disable: false });
                return false;
            }
            // Check for special characters in name
            if(/^[^A-Z]+$/.test(name) === false) {
                $(this).notifie({ type: 'alert', severity: 'danger', message: 'Your slug must be lowercase.', disable: false });
                return false;
            }
            
            // Check for special characters in name
            if(/^[a-zA-Z0-9- ]*$/.test(name) === false) {
                $(this).notifie({ type: 'alert', severity: 'danger', message: 'Your slug contains illegal characters.', disable: false });
                return false;
            }
            // check if category already exists
            if($('li[data-id="' + name + '"]').length > 0 && $('input#parent-name').val() !== name){
                $(this).notifie({ type: 'alert', severity: 'danger', message: 'A catagory with that slug already exists.', disable: false });
                return false;
            }
            // Update the li
            var li = $('li[data-id="'+originalCat+'"]').attr({
                "data-id": name,
                "data-display":displayName
            });
            // Update the display
            $('div.category.selected').text(displayName !== '' ? displayName : name).append(" ").append( 
                $('<button>').addClass('btn btn-xs btn-danger delete pull-right').append(
                    $('<i>').addClass('fa fa-inverse fa-close')
                )
            );
            // Update the category via API
            updateCategory(kapp,li,undefined,originalCat,true);
            clearSelectedCategory();
        });

        /* Click event to show add category from blank item or header button */
        $('div.page-header button.add-category, a.add-category').on('click',function(){
            // Deselect selected
            clearSelectedCategory();
            // Show Edit form
            $('div[heading="Add Category"]').show();
            $('#add-category').slideDown('fast');
        });

        /* Add button event to add cats */
        $('div#panel-add-cat button.add-category').on('click', function(event){
            $('div.workarea').notifie({ exit: true });
            $('button.add-category').notifie({ exit: true });
            event.preventDefault();
            var kapp = $('div.manage-categories').attr('data-slug'), name = $('#category-name').val(), displayName = $('#display-name').val(), parent = $('input#parent-name').val();
            // Check if both fields are empty
            if(name.length < 1 && displayName.length < 1) {
                $(this).notifie({ type: 'alert', severity: 'danger', message: 'Both fields cannot be empty.', disable: false });
                return false;
            }
            // Check for special characters in name
            if(/^[^A-Z]+$/.test(name) === false) {
                $(this).notifie({ type: 'alert', severity: 'danger', message: 'Your slug must be lowercase.', disable: false });
                return false;
            }
            // Check for special characters in name
            if(/^[a-zA-Z0-9- ]*$/.test(name) === false) {
                $(this).notifie({ type: 'alert', severity: 'danger', message: 'Your slug contains illegal characters.', disable: false });
                return false;
            }
            // check if category already exists and is not this item
            if( $('li[data-id="' + name + '"]').length > 0){
                $(this).notifie({ type: 'alert', severity: 'danger', message: 'A catagory with that slug already exists.', disable: false });
                return false;
            }
            // Create the category
            createCategory(kapp,name,displayName,undefined, parent);
        });

        /* Add click event to delete category */
        $('div.workarea').on('click', 'button.delete', function(event){
            $('div.workarea').notifie({ exit: true });
            $('button.add-category').notifie({ exit: true });
            event.stopImmediatePropagation();
            var name = $(this).closest('li').attr('data-id');
            deleteCategory($('div.manage-categories').attr('data-slug'),name);
        });

        // Copy slug from name same as is done in the builder
        $("input#change-display").on("keyup", function(){
            $("input#change-name").val($(this).val().trim().toLowerCase().replace(/[^a-z\s-]/g, "").replace(/\s+/g, '-'));
        }).one("keyup", "input#change-name", function(){
            $("input#change-display").off("keyup");
        });
        $("input#display-name").on("keyup", function(){
            $("input#category-name").val($(this).val().trim().toLowerCase().replace(/[^a-z\s-]/g, "").replace(/\s+/g, '-'));
        }).one("keyup", "input#category-name", function(){
            $("input#display-name").off("keyup");
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
        if(parent.length > 0){
            var attributes = "";
            if(parent != undefined && parent.length > 0) { 
                attributes = attributes + '{"name":"Parent","values": ["' + parent + '"]},';
            }

            payload = '{"attributes": [' + attributes.substring(0,attributes.length-1) + '], "slug": "' + categoryName + '","name": "' + displayName + '"}';
            url = url + '?include=attributes';
        }
        else {
            payload = '{"slug": "' + categoryName + '","name": "' + displayName + '"}';
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
                        'data-display': displayName
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
                updateCategory(kapp,li,undefined,undefined,true);
                clearSelectedCategory();
            },
            error: function(jqXHR){
                $('div.workarea').notifie({ type: 'alert', severity: 'danger', message: 'There was an error creating the category.', disable: false});
            }
        });
    }

    // Create siblings array
    var siblingsArray = [];
    // Update a current category
    function updateCategory(kapp,obj,stopSiblings, originalCategory, deselectCategory) {
        if(siblingsArray.length === 0){
            siblingsArray = $(obj).siblings('li');
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

        // Get category to add other attributes
        $.ajax({
            method: 'GET',
            url: url,
            dataType: "json",
            contentType: "application/json",
            success: function( data ){
                // Create the payload by what is defined
                var payload = '{"slug": "' + categoryName + '","name": "' + displayName + '",';
                // These are attributes 
                payload = payload + '"attributes": [ ';
                if( sortOrder != undefined ||  parent != undefined){
                    if(sortOrder != undefined){
                        payload = payload + '{ "name":"Sort Order","values":["' + sortOrder + '"]},';
                    }   
                    if(parent != undefined){
                        payload = payload + '{ "name":"Parent","values":["' + parent + '"]},';
                    }
                }
                // Add attributes besides sort and parent
                $.each(data.category.attributes, function(index,value){
                    var stringVal = JSON.stringify(value);
                    if(stringVal.indexOf('Sort Order') > -1){
                    }
                    else {
                        payload = payload + stringVal + ",";
                    }
                });
                payload = payload.substring(0,payload.length-1) + '] '; 
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
                    // Check if we should update siblings
                    if(!stopSiblings){
                        // If this is the last sibling set the stop
                        if(siblingsArray.length === 1) {stopSiblings = true;}
                        var item = siblingsArray[0];
                        siblingsArray.splice(0,1);
                        updateCategory(kapp,$(item),stopSiblings,undefined,false);
                    }
                });
                $('ul.sortable').sortable();
                if(deselectCategory){
                    clearSelectedCategory();
                }
            }
        });
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
            /*if(confirm('Do you want to delete this category? It will also delete all children.')){
                deleteCat(kapp,categoryName);
                // Deselect selected
                clearSelectedCategory();
            }*/
            // Build the modal. - Waiting on updated core code.
            modal = new KD.Modal({
                    header: '<h3>Confirm Delete</h3>',
                    body: 'Do you want to delete this category? It will also delete all children.',
                    footer: function(element, actions) {
                        element.append(
                            $('<button>').addClass('btn btn-success').text('OK').on('click',function(){
                                deleteCat(kapp,categoryName);
                                actions.dismiss();
                            }),
                            $('<button>').addClass('btn btn-link').text('Dismiss').on('click',function(){
                                actions.dismiss();
                            })
                        );
                    },
                    backdrop: true,
                    backdropclose: true,
                    keyboardclose: true,
                    renderCallback: false,
                    size: "sm"
                });
            modal.show();
        }

        function deleteCat(kapp,categoryName){
            payload = '{"slug": "' + categoryName + '"}';
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
                $('#parent-name').val('');
                $('li[data-id="' + categoryName + '"]').remove();
                // Delete children
                if(deleleteArray.length > 0){
                    deleteCategory(kapp,$(deleleteArray[0]).attr('data-id'),true);
                    deleleteArray.splice(0,1);
                }
            })
        }
    }

    function clearSelectedCategory(){
        // Remove selected class
        $('div.category.selected').removeClass('selected');
        // Hide edit forms, messages, and delete buttons
        $('div[heading="Edit Category"], div[heading="Add Category"], button.delete').hide();
        // Change title to Add Category 
        $('div.panel-title.add-category').text('Add Category');
        // Empty out the form fields
        $('#category-name, #display-name, #parent-name, #change-display, #change-name').val(''); 
    }
})(jQuery, _);



