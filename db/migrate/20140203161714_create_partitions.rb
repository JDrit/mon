class CreatePartitions < ActiveRecord::Migration
  def change
    create_table :partitions do |t|
      t.references :computer
      t.string :name
      t.decimal :cap
      t.decimal :usage

      t.timestamps
    end
  end
end
