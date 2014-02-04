class AddIoUsage < ActiveRecord::Migration
  def change
      add_column :disks, :read, :decimal
      add_column :disks, :write, :decimal
  end
end
