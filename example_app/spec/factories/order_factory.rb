memo_words = %W[ black blue brown green purple red white yellow ]

Factory.define(:order) do |f|
  f.order_number  rand(239832981)
  f.memo memo_words[rand(memo_words.length - 1)]
  f.association :customer, :factory => :customer
end