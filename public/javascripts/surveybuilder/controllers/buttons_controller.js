/**
 * @tag controllers, home
 */
$.Controller.extend('Surveybuilder.Controllers.Buttons',
/* @Static */
{
    onDocument: false
},
/* @Prototype */
{
    init: function(){
        if ($.jStorage.get('hideHowto')){
            $('#showHowto').show();
        }
        else{
            $('#hideHowto').show();
        }
    },
    'survey.loadFinished subscribe': function(event, params) {
    	this.disableSaveButton();
        this.disableSaveSFButton();
    },
    
    'buttons.disableSaveButton subscribe': function(event, params) {
    	this.disableSaveButton();
    }, 

    'buttons.disableSFSaveButton subscribe': function(event, params) {
        this.disableSaveButton();
        this.disableSaveSFButton();
    }, 

    /**
     * Disable the save button
     */
    disableSaveButton: function() {
    	$('#saveAll').addClass('disabled').attr("disabled", true);
    },

    disableSaveSFButton: function() {
        $('#saveSF').addClass('disabled').attr("disabled", true);
    },
        
    'buttons.enableSaveButton subscribe': function(event, params) {
    	this.enableSaveButton();
        this.enableSaveSFButton();
    },
        
    /**
     * Enable the save button
     */
     enableSaveButton: function(){
     	$('#saveAll').removeClass('disabled').attr("disabled", false);
     },

     enableSaveSFButton: function(){
        $('#saveSF').removeClass('disabled').attr("disabled", false);
     },
          
    'buttons.showAjaxLoader subscribe': function(event, params) {
    	this.showAjaxLoader();
    },
    
    /**
     * Show the ajax loader
     */
    showAjaxLoader: function() {
    	$('#ajax-loader').show();
    },
    
    'buttons.hideAjaxLoader subscribe': function(event, params) {
    	this.hideAjaxLoader();
    },
    
    /**
     * Hide the ajax loader
     */
    hideAjaxLoader: function() {
    	$('#ajax-loader').hide();
    },
    
    "#saveAll click": function(el, ev){

	    // disable save button and show loader
		OpenAjax.hub.publish('buttons.disableSaveButton', {});
	    OpenAjax.hub.publish('buttons.showAjaxLoader', {});
    	//save off a copy of the internal representations
        Survey.saveToCache();
        //save representaiton in local storage
        Survey.saveLocal(1, 
			function(){
				// hide all "content changed" indicators
				OpenAjax.hub.publish('tabs.markTabsAsUnchanged', {});
				OpenAjax.hub.publish('buttons.hideAjaxLoader', {});
			}, 
			function(){
				OpenAjax.hub.publish('buttons.hideAjaxLoader', {});
				alert('remote save failure');
			}
		);
        
    },

    "#saveSF click": function(el, ev){

        var answer = confirm("Are you sure?")

        if(answer){
            // disable save button and show loader
            OpenAjax.hub.publish('buttons.disableSFSaveButton', {});
            OpenAjax.hub.publish('buttons.showAjaxLoader', {});
            //save off a copy of the internal representations
            Survey.saveToCache();
            //save external representation remotely
            Survey.saveRemote(1,
                function(){
                    // hide all "content changed" indicators
                    OpenAjax.hub.publish('tabs.markTabsAsUnchanged', {});
                    OpenAjax.hub.publish('buttons.hideAjaxLoader', {});
                }, 
                function(){
                    OpenAjax.hub.publish('buttons.hideAjaxLoader', {});
                }
            );

        }
    },
    
    "#exportSurvey click": function(el, ev){
	    OpenAjax.hub.publish('survey.export', {});
        ev.stopPropagation();
    },
    '#hideHowto click': function(el, ev){
        $('.howto').addClass('stay-hidden');
        HIDEHOWTO = true;
        $.jStorage.set('hideHowto', true);
        $(el).hide();
        $('#showHowto').show();
    },
    '#showHowto click': function(el, ev){
        $('.howto').removeClass('stay-hidden');
        HIDEHOWTO = false;
        $.jStorage.set('hideHowto', false);
        $(el).hide();
        $('#hideHowto').show();
    },
    '#collapseAll click': function(el, ev){
        $('.hideable:visible').slideUp();
        $('.ui-icon-triangle-1-s:visible').removeClass('ui-icon-triangle-1-s').addClass('ui-icon-triangle-1-e');
    }
});
