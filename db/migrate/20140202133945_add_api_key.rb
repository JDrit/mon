class AddApiKey < ActiveRecord::Migration
  def change
      add_column :computers, :key, :primary_key
  end
end
