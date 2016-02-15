class AddSoundcloudTokenToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :soundcloud_token, :jsonb
    add_column :users, :soundcloud_response, :jsonb
  end
end
