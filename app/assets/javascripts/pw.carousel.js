var carouselLayout = function(moment) {
    var wrapper = $('.item_wrapper:visible');
    var medium = $('.pw_medium:visible');
    var caption = $('.carousel-caption:visible');

    if (moment === 'resize') {
        medium.css('margin', '0px');
        caption.css('margin', '10px 5px 10px 5px');
        medium.css('width', '');
        caption.css('width', '');
    }


    if (!wrapper.data('fixed') || moment === 'resize') {
        var w_width = $(window).width();
        var w_height = $(window).height();

        var wrapper_width = wrapper.width();
        var wrapper_height = wrapper.height();

        var medium_width = medium.width();
        var medium_height = medium.height();

        var caption_width = caption.width();
        var caption_height = caption.height();

        // var threshold_width = medium_width * 1.5;
        var threshold_width = medium_width * 1.8;


        var topBottomLayout = function() {
            var padding_lr = ( wrapper_width - medium_width ) * 0.5;
            // wrapper.css('padding', '0px');
            medium.css('margin', '0px ' + padding_lr + 'px');
            caption.css('margin', '10px ' + padding_lr + 'px');
            // caption.css('width', '100%');
        }

        var leftRightLayout = function() {
            $('#carousel-example-generic').css('height', '');
            var caption_padding = 5;
            // item_wrapper.css('padding', '0px 10%');

            medium.width(wrapper_width/1.8);
            medium_width = medium.width();
            var width_rest = wrapper_width - medium_width - caption_padding * 2 - 15;
            caption.width(width_rest);

            caption.css('padding-top', '0px');
            caption.css('margin-top', '10px');

        }

        threshold_width > wrapper_width ? topBottomLayout() : leftRightLayout();
        wrapper.data('fixed', true);
    }

    var h_carousel = $('.carousel-inner').outerHeight(true);
    $('#carousel-example-generic').height(h_carousel + 60);

}