class ChangeWatchdogLoad < ActiveRecord::Migration
  def change
    change_column :watchdogs, :cpu_load, :decimal
  end
end
