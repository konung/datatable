# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)


def db_rand(value="")
  if ActiveRecord::Base.connection.adapter_name =~ /postgres/i
    "random(#{value})"
  else
    "rand(#{value})"
  end
end

SalesRep.delete_all && Customer.delete_all && Order.delete_all && Item.delete_all && OrderItem.delete_all

5.times do |i|
  SalesRep.create!(:first_name => "#{i} First", :last_name => "#{i} Last")
end

fnames = %W[ Alice Bob Chuck Dan Elsa Fred George Harry Ingred Jack Kevin Lisa Mike Norbert Oscar Polly Quin Randy Sam Ted Uma Violet Wendy Xena Yanina Zoey ]
lnames = %W[ Anderson Bork Chestnut Dewit Ellis Flannagan Godert Hagen Ingles Jamison Kagy Lain Moris Neely Oakley Polk Quincy Reisser Stanis Talbot Underhill Volk Wagner Xavier Young Zimmerman ]

150.times do  |i|
  sales_rep_id = SalesRep.all[rand(SalesRep.count)].id
  Customer.create!(:sales_rep_id => sales_rep_id,
                  :first_name => fnames[ActiveSupport::SecureRandom.random_number(fnames.length - 1)],
                  :last_name => lnames[ActiveSupport::SecureRandom.random_number(lnames.length - 1)] )
end

100.times do |i| 
  Item.create!(:description => "##{i} Awesome item", :quantity => rand(10), :price => rand * 10)
end

memo_words = %W[ black blue brown green purple red white yellow ]


200.times do |i|
  customer = Customer.limit(1).order(db_rand()).first
  order = customer.orders.create!(:order_number => ActiveSupport::SecureRandom.random_number(239832981),:memo => memo_words[rand(memo_words.length - 1)])
  rand(10).times do
    order.items << Item.limit(1).order(db_rand())
  end
  order.save!
end

