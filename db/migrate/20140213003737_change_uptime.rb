class ChangeUptime < ActiveRecord::Migration
  def change
      change_column :computers, :uptime, :integer
  end
end
