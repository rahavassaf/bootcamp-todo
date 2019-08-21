class AddUserToTask < ActiveRecord::Migration[5.2]
  def change
  	add_column :tasks, :user_id, :integer
  	add_index :tasks, :user_id
  	add_index :tasks, :id
  end
end
