class AddJsonbToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :comments, :responses, :jsonb, null: false, default: '{}'
  end
end
