// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui.min
//= require ckeditor/init
//= require_tree .
//= require "jquery.dataTables"
//= require "cssPopUp"
//= require "jquery_nested_form"
//= require audio.min

var update = false;

function collapseDiv(div) {
	$("#" + div).toggle();
}

function showAll(className) {	
	var allAnswers = $("." + className);
	var display = ($(allAnswers[0]).css("display") == 'none' ? 'block' : 'none');
	for ( i = 0; i < allAnswers.length; i++ ) {
		var a = allAnswers[i];
		$(a).css("display", display);
	}
}

function confirmUpdate() {
	return update = true;
}

function scrollAmount(target, amount) {

}

function getTextForUrl(element) {
	return $("#" + element).val().replace(/[^\w+]+/g, "-").replace(/-$/, "").toLowerCase();
}
