class AddTimestamps < ActiveRecord::Migration
  def change
      add_column :stats, :timestamp, :datetime
      add_column :partitions, :timestamp, :datetime
      add_column :disks, :timestamp, :datetime
      add_column :interfaces, :timestamp, :datetime
  end
end
