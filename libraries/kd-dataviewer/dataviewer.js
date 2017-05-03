/**TODO
Change setValuesFromResults to setFieldsfromResults

**/
/**
Data Viewer CE
**/
(function($){
    // create the dataViewer global object
    DataViewer = typeof DataViewer == "undefined" ? {} : DataViewer;

    /**
     * Code in kd_client.js is preventing the backspace from working on $('.dataTables_filter input'). stopPropigation allows backspace to work.  
     */
    $('body').on('keydown', '.dataTables_filter input', function( event ) {
      event.stopPropagation();
    });

    /**
     * Define default properties for the Search configurations
     * Reduces need to include all properties in a search configuration.  
     * Each Search config my overide these values by including a value of its own.
     * execute: {Function} Function which will execute the search
     * Other properties are used by Datatables.net or its Responsive Plugin.
     */
    /* Define default properties for defaultsBridgeDataTable object. */
    var defaultsBridgeDataTable = {
        resultsContainer : '<table cellspacing="0", border="0", class="display">',
        // Properties specific to DataTables
        paging: true,
        info: true,
        searching: true,
        responsive: {
            details: {
                type: 'column',
            }
        },
    };
    
    /* Define default properties for defaultsBridgeList object. */
    var defaultsBridgeList = {
        resultsContainer : '<div>',
    };

    /**
     * Executes the search for the configured search object.
     * @param {Obj} destination
     * @param {Obj} Search configuration object
     */
    DataViewer.executeSearch = function(destination, configObj) {
        configObj.destination = evaluteObjType(destination);
        if(configObj.before){configObj.before(configObj);};
        //Retrieve and set the Bridge parameter values using JQuery
        var parameters = {};
        if(configObj.resource.parameters){
            $.each(configObj.resource.parameters, function(i,v){
                if(typeof v == "function"){
                    parameters[i] = v();
                }
                else if(typeof v == "string"){
                    parameters[i]=$(configObj.resource.parameters[i]).val();
                }
            });
        } 
        K('bridgedResource['+configObj.resource.name+']').load({
            attributes: configObj.resource.attributes, 
            values: parameters,
            success: function(response) {
                // If Bridge is a "Single" convert it to array to match format of "multiple"
                if(K('bridgedResource['+configObj.resource.name+']').type() == "Single"){
                    configObj.response=[response];
                }
                else{
                    configObj.response = response;
                }
                // If any results or successEmpty is not defined
                if(response!==null && $(configObj.response).size() > 0 || !configObj.successEmpty){
                    // Execute success callback if defined
                    if(configObj.success){configObj.success(configObj);} 
                    // Render Results
                    configObj = configObj.renderer.type(destination, configObj);
                }
                // No records returned
                else{
                    // Execute successEmpty callback if defined
                    if(configObj.successEmpty){configObj.successEmpty(configObj);}
                }
                // Execute complete callback if defined
                if(configObj.complete){configObj.complete(configObj);}
            },
            error: function(response) {
                // Execute error callback if defined
                if(configObj.error){configObj.error(configObj);}
                // Execute complete callback if defined
                if(configObj.complete){configObj.complete(configObj);}
            },
        });

    };
       
    /**
     * Builds a response obj from Field values and render the results.
     * @param {Obj} destination
     * @param {Obj} Search configuration object
     */
    DataViewer.renderFieldValues = function(destination, configObj) {
        // Initialize the response if not defined
        configObj.response = typeof configObj.response=="undefined" ? [] : configObj.response
        var fieldValueObj = {};
        // Get Field Values and place into an object
        $.each(configObj.data, function(i,v){
            var field = K('field['+v["setField"]+']');
            if(v["setField"]!="" && typeof v["setField"] != "undefined" && field){
               fieldValueObj[v["setField"]] = field.value();
            }
        })
        // Add object to the response Array
        configObj.response.push(fieldValueObj);
        // Render Results
        configObj = configObj.renderer.type(destination, configObj);
    }
    
    /**
     * Renders the results fo a Search configuration object.
     * @param {Obj} destination
     * @param {Obj} Search configuration object
     */
    DataViewer.renderResults = function(destination, configObj) {
        // Render Results
        configObj = configObj.renderer.type(destination, configObj);
    }

    /****************************************************************************
        PRIVATE HELPERS / SHARED FUNCTIONS                             
    ****************************************************************************/

    /**
    * Set Values from selected row
    * @params {Object} data config object
    * @params {Object} data returned from selection.
    */
    function setValuesFromResults(configData, results){ //rowCallback
        $.each(configData, function( k, v){
            var field = K('field['+v["setField"]+']');
            if(v["setField"]!="" && typeof v["setField"] != "undefined" && field){
                field.value(results[v.name]);
            }
            // If callback property exists
            if(v.callback){v.callback(results[k]);}
        });
    }

    /**
     * Returns object 
     * @param {Object} table
     */
    function evaluteObjType(obj){
        // Append to DOM
        if(obj instanceof $){ // if jQuery Obj
            obj = obj;
        }
        else if(typeof obj == "string"){ // if string
            obj = $(obj);
        }
        else if(typeof obj == "function"){ // if function
            obj = obj();
        }
        return obj;
    }

    /**
     * Returns Search Object
     * Creates resultsContainer and adds it to DOM based on Search Config
     * @param {Object} Search Object
     */ 
    function initializeResultsContainer(obj){
        if($("#"+obj.resultsContainerId).length == 0){
            // Create resultsContainer
            if(typeof obj.resultsContainer == "string"){ // if string
                obj.resultsContainer = $(obj.resultsContainer).attr('id',obj.resultsContainerId);
            }
            else if(typeof obj.resultsContainer == "function"){ // if function
                obj.resultsContainer = obj.resultsContainer().attr('id',obj.resultsContainerId);
            }
            // Append to DOM
            if(obj.destination instanceof $){ // if jQuery Obj
                obj.destination.append(obj.resultsContainer);
            }
            else if(typeof obj.destination == "string"){ // if string
                obj.destination = $(obj.destination).append(obj.resultsContainer);
            }
            else if(typeof obj.destination == "function"){ // if function
                obj.destination = obj.destination().append(obj.resultsContainer);
            }
            return obj;
        }
        return obj;
    }

    /**
    * Convert the "data" property into "columns", necessary for DataTables.
    * @param {Object} Search Object to convert
    */
    function convertDataToColumns(obj){
        obj.columns = [];
        $.each(obj.data, function(attribute, attributeObject){
            attributeObject["data"] = attributeObject.name;
            obj.columns.push(attributeObject)
        });
    }


    
    /****************************************************************************
                                PUBlIC FUNCTIONS                               
    ****************************************************************************/
    
    /**
    * Returns string with uppercase first letter
    * @param {String} Value to be give uppercase letter
    */
    DataViewer.ucFirst = function(str){
        var firstLetter = str.substr(0, 1);
        return firstLetter.toUpperCase() + str.substr(1);
    }

    /****************************************************************************
                                RENDERERS                               
    ****************************************************************************/
    DataViewer.Renderers={
        /**
        * Create a TableTable using a Search Object
        * @param {Object} Search Object used to create the DataTable
        */
        DataTables:  function(destination, configObj){
            // Entend defaults into the configuration
            configObj=$.extend( {}, defaultsBridgeDataTable, configObj );  
            // Merge Render options into Config Obj
            configObj=$.extend( true, {}, configObj, configObj.renderer.options );
            // Create a table element for Datatables and add to DOM
            configObj.destination=destination;
            configObj=initializeResultsContainer(configObj);
            // Set columns, need by DataTables
            convertDataToColumns(configObj);
            // Set data, needed by DataTables
            configObj.data = configObj.response;
            // Append Column to beginning of table contain row expansion for responsive Plugin
            if(configObj.responsive){
                configObj.columns.unshift({
                    title: '&nbsp',
                    defaultContent: '',
                    class: 'control',
                    orderable: false,
                });
            }
            if(typeof configObj.processSingleResult != "undefined" && configObj.processSingleResult && $(configObj.data).size() == 1){
                // If it exists destroy DataTable
                if (  $.fn.DataTable.isDataTable( '#'+configObj.resultsContainerId ) ) {
                    $('#'+configObj.resultsContainerId).DataTable().destroy([true]);
                }
                //Set Results to Fields
                setValuesFromResults(configObj.columns, configObj.data[0]);
                //Execute ClickCallback
                if(configObj.clickCallback){configObj.clickCallback(configObj.data[0]);}
            }
            else{
                 // Set property to destroy any DataTable which may already exist.
                configObj.destroy = true;
                configObj.tableObj = $('#'+configObj.resultsContainerId).DataTable( configObj );
                // Bind Click Event based on where the select attribute extists ie:<tr> or <td>
                $('#'+configObj.resultsContainerId).off().on( "click", 'td', function(event){
                    // Ensure user has not clicked on an element with control class (Used by the responsive plugin to expand info)
                    if(!$(this).hasClass('control')){
                        setValuesFromResults(configObj.columns, configObj.tableObj.row($(this).closest('tr')).data());
                        if(configObj.clickCallback){configObj.clickCallback($(this).closest('tr'), configObj.tableObj.row($(this).closest('tr')).data());}
                        if(configObj.removeOnClick || typeof configObj.removeOnClick == "undefined"){
                            // Destroy DataTable and empty container in case columns change.
                            configObj.tableObj.destroy();
                            $('#'+configObj.resultsContainerId).empty();
                        }
                    }
                });
            }
            return configObj;
        },
        UnorderedList: function(destination, configObj){
            // Entend defaults into the configuration
            configObj=$.extend( {}, defaultsBridgeList, configObj );
            // Merge Render options into Config Obj
            configObj=$.extend( true, {}, configObj, configObj.renderer.options );
            // Create a results element for Datatables and add to DOM
            configObj.destination=destination;
            obj=initializeResultsContainer(configObj);
            if(typeof configObj.processSingleResult != "undefined" && configObj.processSingleResult && $(configObj.response).size() == 1){
                //Destroy List
                $('#'+configObj.resultsContainerId).remove();
                //Set Results to Fields
                setValuesFromResults(configObj.data, configObj.response[0]);
                //Execute ClickCallback
                if(configObj.clickCallback){configObj.clickCallback(configObj.response[0]);}
            }
            else{
                this.$resultsList = $('<ul/>').attr('id','resultList');
                var self = this; // reference to this in current scope
                //Iterate through row results to retrieve data
                $.each(configObj.response, function(i,record){
                    self.$singleResult = $('<li/>').attr('id', 'result');
                    //Iterate through the configured columns to match with data returned from bridge
                    $.each(configObj.data, function(attribute, attributeObject){
                        if (typeof record[attributeObject.name] != "undefined" || typeof attributeObject["defaultContent"] != "undefined"){
                            var title ="";
                            if(attributeObject["title"]){
                                var $title = $('<div/>').addClass("title " + attributeObject['class']).html(attributeObject["title"]);
                                self.$singleResult.append($title);
                            }
                            var contentValue = "";
                            if (typeof attributeObject["defaultContent"] != "undefined") {
                                contentValue = attributeObject["defaultContent"];
                                self.$singleResult.data(attributeObject.name,attributeObject["defaultContent"]);
                            } else {
                                contentValue = record[attributeObject.name];
                                self.$singleResult.data(attributeObject.name,record[attributeObject.name]);                             
                            }
                            if (typeof attributeObject["render"] != "undefined") {
                                contentValue = attributeObject["render"](contentValue);
                            }
                            var $value = $('<div/>').addClass(attributeObject['class']).html(contentValue).data('name', attributeObject["name"]);
                            self.$singleResult.append($value); 
                            
                        }
                    });
                    self.$resultsList.append(self.$singleResult);
                });
                $("#"+configObj.resultsContainerId).empty().append(this.$resultsList);
                $("#"+configObj.resultsContainerId).off().on( "click", 'li', function(event){
                    setValuesFromResults(configObj.data, $(this).data());
                    if(configObj.clickCallback){configObj.clickCallback($(this), $(this).data());};
                    if(configObj.removeOnClick || typeof configObj.removeOnClick == "undefined"){
                        $("#"+configObj.resultsContainerId).empty();
                    }
                });
            }
            return configObj;
        }
    } 

    /****************************************************************************
                                Render Utilities   
                            Used to render Data results
    ****************************************************************************/   
    
    DataViewer.render={
        // Render using moment.js
        moment:   function ( options ) {
            //Default Options
            var options = options || {};
            var from = options.from || '';
            var to = options.to || 'MMMM Do YYYY, h:mm:ss a'; 
            var locale = options.locale || 'en';

            return function ( d, type, row ) {
                var m = window.moment( d, from, locale, true );
         
                // Order and type get a number value from Moment, everything else
                // sees the rendered value
                return m.format( type === 'sort' || type === 'type' ? 'x' : to );
            };
        },
    }
      
    /****************************************************************************
                                 Utilities   
    ****************************************************************************/   
    /**
    * Jquery plugin for Unordered Lists
    * Creates functionality similar to DataTables plugin.
    */
    $.fn.UnorderedList = function(){
        var self = this;
            /**
            * Returns List as JSON obj
            */
            var data = function(){
            var array = [];
            $(self).find('li').each(function(i,v){
                 var obj = {};
                 $(v).find("div:not('.title')").each(function(i,v){
                    obj[$(v).data('name')]     = $(v).text()
                 });
                 array.push(obj);
            });
            return array;
        }
        return {
            data: data
        }
    };
})(jQuery);