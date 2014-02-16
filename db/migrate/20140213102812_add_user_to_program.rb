class AddUserToProgram < ActiveRecord::Migration
  def change
      add_column :programs, :user, :string
  end
end
