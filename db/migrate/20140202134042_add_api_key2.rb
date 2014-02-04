class AddApiKey2 < ActiveRecord::Migration
  def change
      remove_column :computers, :key
      add_column :computers, :api_key, :primary_key
  end
end
