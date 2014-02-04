class CreateComputers < ActiveRecord::Migration
  def change
    create_table :computers do |t|
      t.string :api_key
      t.string :name

      t.timestamps
    end
    add_index :computers, :api_key, unique: true
  end
end
