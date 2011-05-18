Factory.define(:order) do |f|
  f.order_number  42
  f.memo  "memo"
  f.association :customer, :factory => :customer
end