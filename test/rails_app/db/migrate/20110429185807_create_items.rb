class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.text :description
      t.integer :quantity
      # t.float :price

      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end
