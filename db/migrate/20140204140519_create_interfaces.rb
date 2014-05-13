class CreateInterfaces < ActiveRecord::Migration
  def change
    create_table :interfaces do |t|
      t.references :computer, index: true
      t.string :name
      t.integer :rx
      t.integer :tx

      t.timestamps
    end
  end
end
