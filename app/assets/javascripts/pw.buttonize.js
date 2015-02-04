var buttonize = function(this_el) {

  var set_actve = function(el){
    if ($(el).is(':checked')){
      $(this_el).find( "label[for=" + $(el).attr("id") + "]" ).addClass('provider-state-active');
    }else{
      $(this_el).find( "label[for=" + $(el).attr("id") + "]" ).removeClass('provider-state-active');
    }
  };

  var set_hover_state = function(el) {
    if ($(el).prev().is(':checked')) {
      $(el).bind("mouseover", function() { $(this).addClass('active-hover-state') })
           .bind("mouseout", function() { $(this).removeClass('active-hover-state') });
    }
    else {
      $(el).bind("mouseover", function() { $(this).addClass('inactive-hover-state') })
           .bind("mouseout", function() { $(this).removeClass('inactive-hover-state') });
    }
  };

  this_el.find('input:checkbox').each( function(){ set_actve(this) })
                                .addClass('hidden-accessible')
                                .bind("click", function() { set_actve(this); set_hover_state($(this).next()) });

  this_el.find('label').each( function() { set_hover_state(this) });
  
  toggle_check(this_el.find(".pw_toggle_check"));
};

var toggle_check = function(this_el) {
  $( this_el ).click(function(e) {
    if (!$(this).closest('form').find("input[type='checkbox']:not(:checked)").length) {
      $(this).closest('form').find("input[type='checkbox']:checked").click();
    }
    else {
      $(this).closest('form').find("input[type='checkbox']:not(:checked)").click();
    }
    e.preventDefault();
  });
}