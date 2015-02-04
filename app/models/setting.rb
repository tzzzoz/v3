class Setting < ActiveRecord::Base
  belongs_to :user

  validates :user_id, :presence => true

  serialize :display_params
  serialize :border_color_provider
  
  def display_params_display_text
     display_params['display_text']
  end

  def display_params_display_text=(val)
   display_params['display_text'] = val
  end

  def display_params_previsualisation
   display_params['previsualisation']
  end

  def display_params_previsualisation=(val)
   display_params['previsualisation'] = val
  end

end