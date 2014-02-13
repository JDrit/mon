class AddTimestampIndex < ActiveRecord::Migration
  def change
    add_index :programs, :timestamp
  end
end
