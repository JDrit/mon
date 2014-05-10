class CreateWatchdogs < ActiveRecord::Migration
  def change
    create_table :watchdogs do |t|
      t.references :user, index: true
      t.references :computer, index: true
      t.integer :cpu_load
      t.decimal :memory_usage
      t.integer :disk_read
      t.integer :disk_write
      t.integer :rx
      t.integer :tx
      t.integer :disk_percentage_left
      t.timestamps
    end
  end
end
