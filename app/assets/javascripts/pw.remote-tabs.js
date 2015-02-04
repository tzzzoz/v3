$( document ).on( "click", ".pw_remote-tabs a", function(e) {
 	var self = $(this);
    var tab_content = self.closest('.pw_remote-tabs').children('.tab-content');
    
    fill_tab_content(tab_content);
    var self_content = tab_content.find('div[id='+self.parent().attr('name')+']');

    if (self.parent().hasClass('active')) {
        self_content.collapse('toggle');
        tab_content.hide();
        self.parent().removeClass('active');
    }
    else{
        tab_content.show();
        self_content.collapse('toggle');
        if (!self.is($.rails.linkClickSelector) && (self.attr('target') != '_blank') && !self.hasClass('no_remote')) {
            if (!self.attr('anchor')) {
                self.attr('anchor', this.href);
                self.attr('href', '#'+self.parent().attr('name'));
            }
            $.get(self.attr('anchor'), function(data) {
                self_content.addClass('active');
                self_content.html(data);
                self.tab('show');
            });
        } else {
            self_content.addClass('active');
            self.tab('show');
            if (self_content.has('table').length) {
                scrollingTableSetThWidth($('.fixed-header-table'));
                affixStatisticsList();
                scrollingTableSetTdWidth($('.fixed-header-table'));
            };

        };
    };
    e.preventDefault();
 });

var fill_tab_content = function (tab_content) {
    if (tab_content.is(":empty")) {
        tab_content.empty();
        tab_content.parent().find('ul>li').each( function () {
            tab_content.append("<div class='tab-pane fade' id="+$(this).attr('name')+"></div>");
        })
    }
}


 $( document ).on( "submit", ".pw_remote-tabs form", function(e) {
    var self = $(this);
	if (self.data('remote') == undefined ) {
        self.trigger('ajax:before');
        if (this.method == 'get') {
            $.get(this.action+'?'+self.find(':input[value]').serialize(), function(data) {
                self.closest('.tab-content').html("<div class='tab-pane fade active in'>"+data+"</div>");
            });
        } else {
            $.post(
                this.action,
                self.serializeArray(),
                function(data) {
                    // console.log(data);
                    self.closest('.tab-content').html("<div class='tab-pane fade active in'>"+data+"</div>");
            });
        }
	    e.preventDefault();
	}
 });