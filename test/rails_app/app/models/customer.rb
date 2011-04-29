class Customer < ActiveRecord::Base
  belongs_to :sales_rep
end
