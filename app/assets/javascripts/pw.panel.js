$.widget("pw.panel", {

  options: {
    collapsed: true,
    dockable: false
  },

  _create: function() {
   this.header_label = this.element.find(".pw_panel-header-label");
   this.orig_parent = this.element.parent() ;

   this.element.addClass("ui-helper-reset ui-widget ui-widget-content ui-helper-clearfix ui-corner-tl ui-state-default")
       .find(".pw_panel-header")
       .addClass("ui-widget-header ui-corner-tl");

    this.header_label.prepend('<span class="ui-icon"></span>');

    this.header_label.bind( "mouseover.panel" , function() {
      $(this).addClass('ui-state-hover');
    }).bind( "mouseout.panel", function() {
      $(this).removeClass('ui-state-hover');
    }).bind( "click.panel", $.proxy( this.collapse, this ));

    this.collapse();
  },

  _panOpen: function() {
        this.options.collapsed = true;
        this.header_label.find(".ui-icon").removeClass("ui-icon-circle-plus").addClass("ui-icon-circle-minus");
        this.element.find(".pw_panel-content").show();
        this.header_label.addClass('ui-state-active');
        if (this.options.dockable) {
          this.element
                 .removeClass('pw_docked')
                 .width('auto')
                 .appendTo( $(this.orig_parent));
          this.orig_parent.show();
        }
  },

  _panClose: function() {
        this.options.collapsed = false;
        this.header_label.find(".ui-icon").removeClass("ui-icon-circle-minus").addClass("ui-icon-circle-plus");
        this.element.find(".pw_panel-content").hide();
        this.header_label.removeClass('ui-state-active');
        this.header_label.removeClass('ui-state-hover');

        if (this.options.dockable) {
          this.element
                 .addClass('pw_docked')
                 .width( this.orig_parent.outerWidth(true))
                 .appendTo($('#pw_dock'));
          this.orig_parent.hide();
        }

  },

  collapse: function() {
    if (this.options.collapsed) {
    this._panClose();
    } else {
    this._panOpen();
    }
    this._trigger('collapse');
  },

  destroy: function() {
    $.Widget.prototype.destroy.call(this);
  }
});

