class CreateStats < ActiveRecord::Migration
  def change
    create_table :stats do |t|
      t.references :computer, index: true
      t.decimal :load_average
      t.decimal :memory_usage
      t.decimal :network_up
      t.decimal :network_down

      t.timestamps
    end
  end
end
