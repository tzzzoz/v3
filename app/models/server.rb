class Server < ActiveRecord::Base
  has_many :titles
  has_many :net_messages

  validates :name, :presence => true, :uniqueness => { :case_sensitive => false }
  validates :is_self, :inclusion => { :in =>  [true, false] }
  validates :status, :inclusion  => { :in => %w(public private) }
  validates :which_type, :inclusion  => { :in => %w(CS ADMIN) }

  before_save :update_is_self

  def update_is_self
     if is_self
       t =  Server.all.collect{|s| s.id}-[id]
       Server.where(:is_self => true, :id => t).each{ |s| s.update_attribute(:is_self,false) }
    end
  end

end
