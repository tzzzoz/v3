// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function PwStatisticsTable(){
  $("#pw_statistics tr:not(.pw_c_header)").hide();

  function show_fold() {
        $("#pw_statistics tr:not(.pw_c_header)").show();
        $("#pw_statistics .pw_c_header-label").addClass("ui-state-active")
                                            .find(".ui-icon")
                                            .removeClass("ui-icon-circle-plus")
                                            .addClass("ui-icon-circle-minus");
        $(".toggle_fold_all").one("click", hide_fold);
  };
  function hide_fold() {
        $("#pw_statistics tr:not(.pw_c_header)").hide();
        $("#pw_statistics .pw_c_header-label").removeClass("ui-state-active")
                                            .find(".ui-icon")
                                            .removeClass("ui-icon-circle-minus")
                                            .addClass("ui-icon-circle-plus");
        $(".toggle_fold_all").one("click", show_fold);
  };

  $(".toggle_fold_all").one("click", show_fold);


  function show_label(itis){
    $(itis).parent().nextUntil(".pw_c_header").show();
    $(itis).addClass("ui-state-active");
    $(itis).find(".ui-icon").removeClass("ui-icon-circle-plus")
                            .addClass("ui-icon-circle-minus");
    $("#pw_statistics .pw_c_header-label").one("click", hide_label(itis));
  };
 function hide_label(itis){
    $(itis).parent().nextUntil(".pw_c_header").hide();
    $(itis).removeClass("ui-state-active");
    $(itis).find(".ui-icon").removeClass("ui-icon-circle-minus")
                            .addClass("ui-icon-circle-plus");
    $("#pw_statistics .pw_c_header-label").one("click", show_label(itis));
  };

  $("#pw_statistics .pw_c_header-label").one("click", show_label(this));

  // $("#pw_contacts .pw_c_header-label").click(function(){
  //     $(this).parent().nextUntil(".pw_c_header").toggle();
  //     $(this).find(".ui-icon").toggleClass("ui-icon-circle-minus");
  // });
  $("#pw_statistics .pw_c_header-label").mouseover(function(){
    $(this).addClass('ui-state-hover');
  });
  $("#pw_statistics .pw_c_header-label").mouseout(function(){
    $(this).removeClass('ui-state-hover');
  });
  
};




function collapseLightBox() {
  $('#pw_right .hidden_button').attr('class','hidden_button glyphicon glyphicon-plus-sign')
  $('#pw_right').attr('style', 'padding:4px').css('position', 'static');
  $('#navigation2 ul').append($('#pw_right'));
  $('.container_wrapper #pw_right').remove();
  PwLayout();
}



function expandLightBox() {
  $('#pw_right').attr('style', 'padding:0px');
  $('.container_wrapper').append($('#pw_right'));
  $('#navigation2 ul #pw_right').remove();
  $('#pw_right .pw_panel-content').collapse('show');
  $('#pw_right .hidden_button').attr('class','hidden_button glyphicon glyphicon-minus-sign');
  PwLayout();
}


var linkCombined = function() {
  $('.multi').unbind('mouseover mouseout').bind('mouseover mouseout', function(ev){
    if (ev.type == 'mouseover') {
      curr_href = $(this).attr('href');
      if ($(this).attr('href').indexOf("?") > 0 ){
        $(this).attr('href', curr_href+'&'+PwSelection('ids[]='));
      } else {
        $(this).attr('href', curr_href+'?'+PwSelection('ids[]='));
      }
    }

    if (ev.type == 'mouseout') {
      $(this).attr('href', curr_href);
    }
  });
}
// to use with PwLayout for ie (later)...
// function scrollbarWidth() {
//     var div = $('<div style="width:50px;height:50px;overflow:hidden;position:absolute;top:-200px;left:-200px;"><div style="height:100px;"></div>');
//     // Append our div, do our calculation and then remove it
//     $('body').append(div);
//     var w1 = $('div', div).innerWidth();
//     div.css('overflow-y', 'scroll');
//     var w2 = $('div', div).innerWidth();
//     $(div).remove();
//     return (w1 - w2);
// }
// or even better (after tests) :
//console.debug($('#pw_right').scrollLeft($('#pw_right').outerWidth(true)).scrollLeft());


function PwLayout() {
  var r_width = $('.container_wrapper #pw_right:visible').outerWidth(true);
  var t_height = $('#pw_top:visible').outerHeight(true);
  var container_width = $('.container_wrapper').width();
  var w_width = $(window).width();
  var w_height = $(window).height();
  var vertical_margin = 4;
  var horizontal_margin = 4;
  
  $('body').height(w_height);
  $('#pw_top:visible').width(w_width);

  $('#pw_center:visible').width(container_width - r_width).css('margin-top', horizontal_margin).height(w_height - t_height - vertical_margin);

  if ($("#pw_top:visible").hasClass("navbar-fixed-top")) {
    $('.container_wrapper').height(w_height).css('padding-top', t_height);
  };

  $('#pw_right:visible').height(w_height - t_height - horizontal_margin).css('margin-top', horizontal_margin);
};


function scrollingTableSetThWidth(table) {
  var firstRow = table.find('tbody tr:first');
  if (firstRow.length === 0) {firstRow = table.next().find('tbody tr:first')};
  table.find('thead').css('width', firstRow.width());
  table.find('thead th').each(function(j,k){
    $(k).css({width:firstRow.find('td:eq('+j+')').outerWidth()});
  });
};

function scrollingTableSetTdWidth(table) {
  var thead = table.find('thead tr:first');
  var firstRow = table.find('tbody tr:first');
  table.find('tbody tr').each(function(){
    $(this).find('td').each(function(j,k){
      $(k).css({width:thead.find('th:eq('+j+')').outerWidth()});
    });
  })
};


var getCenter = function ($element) {
  var offset = $element.offset();
  var width = $element.width();
  var height = $element.height();
  var viewportHeight = $(window).height();
  var viewportWidth = $(window).width();
  var center = {top : 0, left : 0};
  center.top = offset.top + height * 0.5;
  center.left = offset.left + width * 0.5;
  return center;
}

var getPlacement = function (source) {
  var target = $(source);
  var center = getCenter($(source));
  var viewportWidth = $(window).width();
  var bound = {top : 0, left : 0};
  placement = center.left < viewportWidth * 0.5 ? 'right' : 'left';
  return placement;
}



function PwThumbRollo(){
  $(".popover-trigger").popover({
    trigger: "hover"
    , placement:  function () {
      return getPlacement(this.$element);
    }
    , html: true
    , content: function(){return $(this).attr('data-c');}
    , viewport: ".container_wrapper"
  }).on('shown.bs.popover', function(e){
    e.preventDefault();
    var popover = $(this).next();
    var offset = popover.offset();
    var image = popover.find('img');
    var popover_content = image.parent();
    var viewportHeight = $(window).height();
    var center = getCenter($(this));
    // popover.css('max-width',image.outerWidth(true)+parseInt(popover_content.css('padding-left'))+parseInt(popover_content.css('padding-right')));
    center.top < viewportHeight * 0.3 ? (offset.top < 0 ? popover.offset({top : 0}) : '') :
    (offset.top > viewportHeight - popover.outerHeight(true) - 20) ? (popover.offset({top : viewportHeight - popover.outerHeight(true) - 30})) : '';
  })
}

// Settings


function conv_rgb(v){
    return "rgb("+v+","+v+","+v+")";
}

function changeBgColor(v){
    value = conv_rgb(v);
    $('#pw_search_form, .dropdown-menu, .popover-content, #search_tabs, #navigation2, .panel-heading, .panel-header, .pw_panel-header, pw_search_form, .pw_panel-content, .pw_menu_2, #tabs-thumbs .ui-widget-content, .pw_info_thumb, .pw_content, .content, .pw_remote-tabs, #pw_light_box_panel, #pw_search_form .ui-state-hover, #pw_search_form .ui-state-focus, #light_box_form_place .ui-state-focus, #light_box_form_place .ui-state-hover, .pw_panel-header-label.ui-state-focus, .pw_panel-header .pw_panel-header-label, ul.pw_submenu li,#select_pictures_form, .result_content').css('backgroundColor', value);
    $('#pw_search_form, .panel-header, #pw_header .ui-widget-header, #pw_center .ui-widget-header, #pw_center .ui-widget-content, #pw_right .ui-widget-header, #pw_light_box_panel').css('border-color', value);
}

function changeFtColor(v){
    value = conv_rgb(v);
    $('table#pw_statistics_list tbody, #pw_search_form, #pw_media_all, #navigation2 a, .pw_panel-header, .pw_panel-content, .pw_thumb p, .pw_stats_thumb p, .pw_info_thumb, .pw_panel-header .ui-state-active, .pw_total_photos, .gap, .pw_toggle_check, .pw_stats_total, .pw_content, .pw_content a, .content, .content a, .carousel-caption').css('color', value);
    $('.pw_menus li a, .pw_menu_2 li, .pw_menu_2 li a, .pw_submenu li a, .pw_menus_3 li a, .pw_stats_export a, .pw_panel-header-content a.pw_tpgn_link, .pw_title_panel,#select_pictures_form').css('color', value);
    $('.reportages_main_title a,.reportages_selection a,.reportages_table_header th a').css('color', value+" !important");
    //$('.pw_menus li a:link, .pw_menus li a:visited, .pw_menu_2 li a:visited, .pw_menu_2 li a:link, .pw_menus_3 li a:link, .pw_menus_3 li a:visited, .pagination a:link, .pagination a:visited, .pw_stats_export a:link, .pw_stats_export a:visited').css('color', value);
}
// Statistics


function PwStats(){


    //results
    // $('#pw_results_stats').tabs({
    //     cookie: { expires: 1, name: 'pw_results_stats-tabs'},
    //     collapsible: false
    // });
  // $("#pw_statistics_list tr:not(.pw_statistics_list_titles)").on("click", function () {
  //   if ($(this).hasClass("pw_stats_list_hover")) {
  //     $(this).removeClass('pw_stats_list_hover');
  //   } else {
  //     $(this).addClass('pw_stats_list_hover');
  //   }
  // });


    //titles & users
    // $('#stats_titles_users').tabs({
    //     collapsible: true,
    //     selected: -1,
    //     load: function(event, ui){

    //         $(".pw_buttonset").buttonize();

    //         $(".pw_toggle_check").toggle(
    //           function(){
    //             $(this).closest('form').find("input:checkbox")
    //                                    .attr('checked', true)
    //                                    .each( function(){ $(this).triggerHandler('click') });
    //           },
    //           function(){
    //             $(this).closest('form').find("input:checkbox")
    //                                    .attr('checked', false)
    //                                    .each( function(){ $(this).triggerHandler('click') });
    //           }
    //         );

    //         $('#pw_user_form .pw_toggle_check').click();
    //     },
    //     cache: true



    // });

}

function PwAdmAgency(){

    //tabs
    $('#pw_admagency').tabs({
        cookie: { expires: 1, name: 'pw_admagency-tabs'},
        collapsible: false
    });

}


$( document ).on("click", ".link_button_in_tabs",  function(e){
    var self = $(this);
    self.next('.link_button').click();
//    $.get(self.data('href'), function(data) {
//        self.closest('.ui-tabs-panel').html(data);
//    });
    e.preventDefault();
});


function flashIt(){
    $("#pw_flash-notice").animate({'opacity':0},4000,function(){$(this).remove()});
    $("#pw_flash-alert").animate({'opacity':0},5000,function(){$(this).remove()});
    $("#pw_flash-warning").modal();
    $("#pw_flash-error").modal();
}


function PwSelection(joiner){
     res = $('#pw_results').find('input:checked')
                           .closest('div')
                           .map(function() { return this.id.replace('main_',''); })
                           .get().join('&'+joiner);
     if (res != '' ){ res = joiner + res; }
     return res
}

function processingRoutine() {
    var swipedElement = document.getElementById(triggerElementID);
    if ( swipeDirection == 'left' ) {
        $('.pagination:first .next_page').click();
    } else if ( swipeDirection == 'right' ) {
        $('.pagination:first .previous_page').click();
    }
}
