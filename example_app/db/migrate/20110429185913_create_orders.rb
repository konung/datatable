class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.integer :customer_id
      t.integer :order_number
      t.string :memo

      t.timestamps
    end
  end

  def self.down
    drop_table :orders
  end
end
