/**
 * @tag controllers, home
 */
$.Controller.extend('Surveybuilder.Controllers.DisplayComponent',
/* @Static */
{
	onDocument: false
},
/* @Prototype */
{
	init: function(){
		steal.dev.log('loaded display component controller');
		// show possible branch targets
		var parentLine = Line.findOne({id:this.element.closest('.line').attr('id')});
		var currentLineitem = Lineitem.findOne({id:this.element.attr('id')});
	}
	
});