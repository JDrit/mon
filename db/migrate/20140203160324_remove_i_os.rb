class RemoveIOs < ActiveRecord::Migration
  def change
      remove_column :disks, :read
      remove_column :disks, :write
  end
end
