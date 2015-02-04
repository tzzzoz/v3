module LightBoxesHelper

    def select_for_current_user_light_boxes
        select("light_box", "id", 
        	current_user.light_boxes.collect {|lb| [ "#{lb.name} (#{lb.images.where(:content_error => 0).count})", lb.id ] })
    end

    def fit_square(ratio,side)
      ratio>1 ? "#{side}x#{(side/ratio).round}" : "#{(ratio*side).round}x#{side}"
    end

end