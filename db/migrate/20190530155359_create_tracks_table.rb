class CreateTracksTable < ActiveRecord::Migration[5.2]
  def change
    create_table :tracks do |col|
      col.string :name
      col.string :artist
      col.string :type
      col.integer :popularity
      col.integer :playlist_id

    end
  end
end
