/**
 * @tag controllers, home
 */
$.Controller.extend('Surveybuilder.Controllers.DisplayCondition',
/* @Static */
{
	onDocument: false
},
/* @Prototype */
{
	init: function(){
		steal.dev.log('loaded display  Condition controller');
		// show possible branch targets
		var parentLine = Line.findOne({id:this.element.closest('.line').attr('id')});
		var currentLineitem = Lineitem.findOne({id:this.element.attr('id')});
		//steal.dev.log('Right opernad selector found : '+rightOperandSelector.val;
		var rightOperandSelector = this.element.find('.right-operand-dataType');
		this.configureCombobox(this.element.find('.leftOperand'), 'survey:predicate');
		this.configureCombobox(this.element.find('.rightOperand'), rightOperandSelector.val());
	},

	configureCombobox: function(el, dataType) {
		var operand = el.val();
		var name = el.attr('name');
		var parent = el.parent();
		//alert('dl '+name+' '+operand);
		switch (dataType) {
			case 'survey:object':
				parent.html($.View('//surveybuilder/views/displayCondition/show_branchOperand', {operand:operand, operandDatatype:dataType, name:name, options:surveyBuilder.OBJECTS}));
				parent.children().first().combobox();
				break;
			case 'survey:predicate':
				parent.html($.View('//surveybuilder/views/displayCondition/show_branchOperand', {operand:operand, operandDatatype:dataType, name:name, options:surveyBuilder.PREDICATES}));
				parent.children().first().combobox();
				break;
			default:
				parent.html($.View('//surveybuilder/views/displayCondition/show_branchOperand', {operand:operand, operandDatatype:dataType, name:name}));
				parent.children().first().combobox("destroy");
				break;
		}
	},

	'predicates.update subscribe': function(event, params) {
		lists = this.element.find('.predicate-list');
		for (var i=0; i < lists.length; i+=1) {
			this.configureCombobox($(lists[i]), 'survey:predicate');
		}
	},	

	'objects.update subscribe': function(event, params) {
		lists = this.element.find('.object-list');
		for (var i=0; i < lists.length; i+=1) {
			this.configureCombobox($(lists[i]), 'survey:object');
		}
	},

	".right-operand-dataType change": function(el, ev) {
		var operandEl = el.closest('.condition').find('.rightOperand');
		this.configureCombobox(operandEl, el.val());
	}
	
});