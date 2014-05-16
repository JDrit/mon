class ChangingMemFormatInWatchdog < ActiveRecord::Migration
  def change
      change_column :watchdogs, :memory_usage, :integer
  end
end
