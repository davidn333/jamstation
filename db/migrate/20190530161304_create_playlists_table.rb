class CreatePlaylistsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :playlists do |col|
      col.string :name
      col.integer :user_id
    end
  end
end
