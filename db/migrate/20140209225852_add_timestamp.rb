class AddTimestamp < ActiveRecord::Migration
  def change
      add_column :programs, :timestamp, :datetime
  end
end
