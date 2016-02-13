class AddStateToComments < ActiveRecord::Migration[5.0]
  def change
    add_column :comments, :now_playing, :boolean, null: false, default: false
    add_column :comments, :aired_at, :datetime
  end
end
