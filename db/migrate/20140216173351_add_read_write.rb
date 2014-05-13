class AddReadWrite < ActiveRecord::Migration
  def change
      add_column :programs, :read, :integer
      add_column :programs, :write, :integer
  end
end
