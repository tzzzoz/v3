<% content_for :document_ready do %>
    $("#pw_rename_light_box").hide();
    $("#rename_div").toggle(
            function(){
                $("#pw_rename_light_box").show();
            },
            function(){
                $("#pw_rename_light_box").hide();
            }
    );
    $(".pw_toggle_check").toggle(
            function(){
                $(this).closest('form').find("input:checkbox")
                   .attr('checked', true)
                   .each( function(){ $(this).triggerHandler('click') });
            },
            function(){
                $(this).closest('form').find("input:checkbox")
                   .attr('checked', false)
                   .each( function(){ $(this).triggerHandler('click') });
            }
    );
    $(document).ready(function() {
	    var $dialog = $('<div></div>')
		    .html('<%= escape_javascript(render :partial => 'full_screen_light_boxes/poplb', :layout => nil) %>')
		    .dialog({
			    autoOpen: false,
			    title: 'Select Light-Box',
                buttons: {
                    'OK': function() {
                        $('#add_image').submit();
                        $(this).dialog('close');
                    },
                    Cancel: function() {
                        $(this).dialog('close');
                    }
                }
		    });

	$('.add_other').click(function() {
        var ids = $(this).attr('id');
        $('#hide_id').attr('value',ids);
        $dialog.dialog('open');

		return false;
	});
});
    <% end %>
    <%= render  :partial => "menus" %>
<div id='pw_light_box_images'>
    <%= render  :partial => "thumbs" %>
</div>
<hr />
 <%= render  :partial => "menus_bas" %>
