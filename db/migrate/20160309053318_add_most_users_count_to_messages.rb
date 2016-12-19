class AddMostUsersCountToMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :messages, :most_users_count, :integer, default: 0
  end
end
