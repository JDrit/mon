class CreatePrograms < ActiveRecord::Migration
  def change
    create_table :programs do |t|
      t.references :computer, index: true
      t.string :name
      t.decimal :load_usage
      t.decimal :memory_usage

      t.timestamps
    end
  end
end
