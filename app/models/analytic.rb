class Analytic < ActiveRecord::Base

  validates :page_id, :presence => true
  validates :user_id, :presence => true

  def self.safe_save(options)
    self.create(:page_id => options[:page_id], :user_id => options[:user_id], :action_id => options[:action_id], :datin => Time.now)
  end

end
