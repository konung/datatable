class CreateSalesReps < ActiveRecord::Migration
  def self.up
    create_table :sales_reps do |t|
      t.string :first_name
      t.string :last_name

      t.timestamps
    end
  end

  def self.down
    drop_table :sales_reps
  end
end
