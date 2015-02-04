class OperationLabel < ActiveRecord::Base
  has_many :statistics
  validates :label, :uniqueness => true
end
