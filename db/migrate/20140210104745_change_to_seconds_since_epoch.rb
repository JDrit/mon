class ChangeToSecondsSinceEpoch < ActiveRecord::Migration
  def change
      remove_column :stats, :timestamp
      remove_column :partitions, :timestamp
      remove_column :disks, :timestamp
      remove_column :interfaces, :timestamp
      remove_column :programs, :timestamp
      add_column :stats, :timestamp, :integer
      add_column :partitions, :timestamp, :integer
      add_column :disks, :timestamp, :integer
      add_column :interfaces, :timestamp, :integer
      add_column :programs, :timestamp, :integer

  end
end
