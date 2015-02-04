
var pwGT, pwGH;

function PwSlide(){
  $( document ).on("click",".pw_slideShow",
    function(){
      var clicked = $(this).data('clicked');

      //start
      if (!clicked) {
        if ($(this).data('slide')==undefined){
          curr = $(this);
          id = $(this).attr('id').split('_');
          id = id[id.length -1];
          $.getJSON( '/searches.json?id=' + id, function(data){
           curr.data('slide', data);
           curr.data('index', 0);
           pwGH = curr;
           PwGTimer();
         });
        } else {
          pwGH = $(this);
          PwGTimer();
        }
      } else {
        //stop
        clearTimeout(pwGT);
      }
      $(this).data('clicked', !clicked);
    }
  )
}

function PwNextSlide(curr){
  ind = curr.data('index');
  curr.find('img').remove();
  ind++
  if(ind==curr.data('slide').length) ind = 0;
  //curr_img = $('<img/>',{ src : curr.data('slide')[ind] }).appendTo(curr);

  curr_img = $('<img/>',{ height : "120px", src : curr.data('slide')[ind] }).appendTo(curr);
  // curr_img.load(function() {
  //   //vertical center
  //   console.debug('loaded');
  //   curr_img.css('padding-top', (curr.height() - curr_img.height()) / 2);
  // });
  curr.data('index', ind);
}

function PwGTimer(){
  clearTimeout(pwGT);
  PwNextSlide(pwGH);
  pwGT = setTimeout("PwGTimer()",1200);
}

function PwCollapsibleTable(){

  $(".toggle_fold_all").click(function() {
    var e = $("#pw_contacts tr:not(.pw_c_header)");
    if (e.is(":visible")) {
      e.hide();
      $(this).find(".glyphicon").removeClass("glyphicon-collapse-down")
                                .addClass("glyphicon-expand");
      $("#pw_contacts .pw_c_header-label").removeClass("ui-state-active")
                                          .find(".glyphicon")
                                          .removeClass("glyphicon-minus-sign")
                                          .addClass("glyphicon-plus-sign");
    }
    else {
      e.show();
      $(this).find(".glyphicon").removeClass("glyphicon-expand")
                                .addClass("glyphicon-collapse-down");
      $("#pw_contacts .pw_c_header-label").addClass("ui-state-active")
                                        .find(".glyphicon")
                                        .removeClass("glyphicon-plus-sign")
                                        .addClass("glyphicon-minus-sign");
    }
  });

  $("#pw_contacts .pw_c_header-label").click(function() {
    var e = $(this).parent().nextUntil(".pw_c_header");
    if (e.is(":visible")) {
      e.hide();
      $(this).removeClass("ui-state-active");
      $(this).find(".glyphicon").removeClass("glyphicon-minus-sign")
                              .addClass("glyphicon-plus-sign");
    } else{
      e.show();
      $(this).addClass("ui-state-active");
      $(this).find(".glyphicon").removeClass("glyphicon-plus-sign")
                              .addClass("glyphicon-minus-sign");
    };
  })

  // $("#pw_contacts .pw_c_header-label").click(function(){
  //     $(this).parent().nextUntil(".pw_c_header").toggle();
  //     $(this).find(".ui-icon").toggleClass("ui-icon-circle-minus");
  // });
  $("#pw_contacts .pw_c_header-label").mouseover(function(){
    $(this).addClass('ui-state-hover');
  });
  $("#pw_contacts .pw_c_header-label").mouseout(function(){
    $(this).removeClass('ui-state-hover');
  });

};

