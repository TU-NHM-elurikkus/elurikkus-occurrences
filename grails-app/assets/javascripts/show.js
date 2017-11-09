//= require common
//= require record-view
//= require ekko-lightbox-5.2.0
//= require leafletPlugins
//= require amplify
//= require jquery_migration

$(function() {
    // Lightbox
    $(document).delegate('*[data-toggle="lightbox"]', 'click', function(event) {
        event.preventDefault();
        $(this).ekkoLightbox();
    });
});
