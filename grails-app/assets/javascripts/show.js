//= require common
//= require jquery.cookie
//= require jquery.inview.min
//= require jquery.jsonp-2.4.0.min
//= require jquery_migration
//= require jquery.autocomplete
//= require charts
//= require ekko-lightbox-5.2.0
//= require leafletPlugins
//= require amplify
//= require purl
//= require nanoscroller
//= require ala-charts
//= require bootstrap-combobox
//= require bootstrap-slider
//= require map.common
//= require occurrenceMap
//= require record-view

$(function() {
    // Lightbox
    $(document).delegate('*[data-toggle="lightbox"]', 'click', function(event) {
        event.preventDefault();
        $(this).ekkoLightbox();
    });
});
