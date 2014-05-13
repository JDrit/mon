class AddUptimeToDecimals < ActiveRecord::Migration
  def change
      add_column :computers, :uptime, :decimal
  end
end
