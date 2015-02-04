$( document ).ready( function(e) {
  var self = $('.pw_params_builder');

  var o = self.options;

  var add_field = function(opt, val){

      if(!opt){
        sele = self.find(':selected');
      }else{
        sele = self.find('option[value='+opt+']');
      }
      if(!val){ val = ''};
        added_field = $('<label>'+sele.text()+'</label><input type="text" name="'+sele.val()+'" value="'+val+'" class="form-control input-xs" />');
        added_remove = $('<div class="pw_params_builder_remove ui-state-focus" ><span class="glyphicon glyphicon-minus"></span></div>')
                  .bind( "click", function(){ remove_field($(this)) });
      
        added_wrapper = $('<div class="pw_params_wrapper"/>');
        added_wrapper.append(added_field);
        added_wrapper.append(added_remove);
        field_container.append(added_wrapper);
        sele.remove();

        if ( self.find(':selected').val() == undefined ){
            self.hide();
            add_field_button.hide();
        }
    };

    var remove_field = function(el){
      curr = el.closest('.pw_params_wrapper');
      curr.remove();
      val = curr.find('input:text').attr('name');
      text = curr.find('label').text();
      self.append($('<option></option>').val(val).html(text));
      self.show();
      add_field_button.show();
    };

    field_container = $('<div class="pw_params_builder_field_container"></div>');
    add_field_button = $('<div class="pw_params_builder_add"><span class="glyphicon glyphicon-plus"></span></div>')
                    .bind( "click", function(){ add_field(); });
    
    field_container.insertAfter(self);
    add_field_button.insertAfter(self);
    
    // for (k in o.fields){
    //  add_field(k, o.fields[k]);
    // }


});
