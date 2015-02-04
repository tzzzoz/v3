/*$.widget("pw.select_manager", {

  options: {
  },

  _create: function() {
    var this_el = this.element;
    var add_el =  $('<div class="pw_select_manager_add ui-state-focus"> <span class="ui-icon ui-icon-plusthick" > </span> </div>');
    var input_el = $('<input type="text" size="12" name="name"/>');
    var submit_el = $('<input type="submit" class="pw_small" value="Ok"/>');

    var turn_to_input = function(){
        $(add_el).hide();
        $(this_el).hide();
        input_el.show()
                .focus();
        submit_el.show();
    };

    var turn_to_select = function(){
        $(submit_el).hide();
        $(input_el).hide();
        $(this_el).show();
        $(add_el).show();
    };

   add_el.insertAfter(this_el)
         .bind( "mouseover" , function() { $(this).addClass('ui-state-hover'); })
         .bind( "mouseout", function() { $(this).removeClass('ui-state-hover'); })
         .bind( "click", function(){ turn_to_input(); });

   input_el.insertAfter(this_el)
           .after(submit_el);

   input_el.hide();
   submit_el.hide();

   this_el.parent().bind('mouseout focusout mouseover', function(ev){
       if (ev.type == 'mouseout'){ out = true };
       if (ev.type == 'mouseover'){ out = false };
       if (ev.type == 'focusout' && out ){ turn_to_select(); }
   }); 
  }

});

*/