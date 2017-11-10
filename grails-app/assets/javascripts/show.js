//= require record-view
//= require ekko-lightbox-5.2.0
//= require amplify

$(function() {
    // Lightbox
    $(document).delegate('*[data-toggle="lightbox"]', 'click', function(event) {
        event.preventDefault();
        $(this).ekkoLightbox();
    });
});
