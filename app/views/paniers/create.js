document.getElementById("tab_selection").innerHTML='<%= link_to "#{I18n.t('features.selection')} (#{@nb_panier})", liste_reps_path(:panier => 1)%>';
var $dialog = $('<div></div>')
 .html('<%= escape_javascript(render :partial => "paniers/alert", :layout => nil) %>')
 .dialog({
  autoOpen: true,
  title: "<%= I18n.t("features.selection")%>",
           buttons: {
               Fermer: function() {
                   $(this).dialog('close');
               }
           }
 });
