class Rename < ActiveRecord::Migration
  def change
      rename_table :disks, :partition
  end
end
