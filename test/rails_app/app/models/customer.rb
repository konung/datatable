class Customer < ActiveRecord::Base
  belongs_to :sales_rep
  has_many :orders
end
