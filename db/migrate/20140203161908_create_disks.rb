class CreateDisks < ActiveRecord::Migration
  def change
    create_table :disks do |t|
      t.references :computer, index: true
      t.string :name
      t.integer :read
      t.integer :write

      t.timestamps
    end
  end
end
