class AddStatToComp < ActiveRecord::Migration
  def change
      add_reference :stats, :computer_id, index:true
  end
end
