# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

5.times do |i|
  SalesRep.create!(:first_name => "#{i} First", :last_name => "#{i} Last")
end

20.times do  |i|
  sales_rep_id = SalesRep.all[rand(SalesRep.count)].id
  Customer.create!(:sales_rep_id => sales_rep_id,
                  :first_name => "#{i} First",
                  :last_name => "#{i} Last")
end

100.times do |i| 
  Item.create!(:description => "##{i} Awesome item", :quantity => rand(10), :price => rand * 10)
end

200.times do |i|
  customer = Customer.limit(1).order('rand()').first
  order = customer.orders.create!
  rand(10).times do
    order.items << Item.limit(1).order('rand()')
  end
  order.save!
end

