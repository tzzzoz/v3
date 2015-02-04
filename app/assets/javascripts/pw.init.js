$(document).on('ready', function(){  

  $('.pw_panel-content').each(function(){    
    if ($.cookie($(this).parents('div:first').attr('id') + '_collapse_state') === 'true') {
      $(this).addClass("collapse");
      var hidden_button = "<span type='button' class='glyphicon glyphicon-plus-sign'></span>";
      $(this).prev().find(".pw_panel-header-label").prepend(hidden_button);
    } else {
      $(this).addClass("collapse in");
      var hidden_button = "<span type='button' class='glyphicon glyphicon-minus-sign'></span>";
      $(this).prev().find(".pw_panel-header-label").prepend(hidden_button);
    }
  })

  // $('#pw_light_box_panel span[type=button]').removeClass('hidden_button').addClass('hide_light_box_button');
  $('.hidden-trigger').on('click', function() {
    var button = $(this).find('[type=button]');
    var parent_id = $(this).parents('.pw_panel-header').parents('div:first').attr('id');
    
    var panel_content = $(this).closest('.pw_panel-header').next('.pw_panel-content');

    // if it is light_box panel, change the layout of page
    if (parent_id === 'pw_light_box_panel') {
      if (panel_content.hasClass('in')) {
        panel_content.collapse('hide');
        panel_content.attr('class','pw_panel-content collapse');
        $('#light_box_add').hide();
        collapseLightBox();
      } else {
        $('#light_box_add').show();
        expandLightBox();
      }
    } else {
      if (panel_content.is(':visible')) {
        button.attr('class','glyphicon glyphicon-plus-sign');
      }
      else {
        button.attr('class','glyphicon glyphicon-minus-sign');
      }
      panel_content.collapse('toggle');
    }
  })

  $('.pw_panel-content').on('shown.bs.collapse', function(){
    $.cookie($(this).parents('div:first').attr('id') + '_collapse_state', 'false', { path: '/', expires: 90 });
  })

  $('.pw_panel-content').on('hidden.bs.collapse', function(){
    $.cookie($(this).parents('div:first').attr('id') + '_collapse_state', 'true', { path: '/', expires: 90 });
  })
})
