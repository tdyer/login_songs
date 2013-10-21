class CreateSongCollections < ActiveRecord::Migration
  def change
    create_table :song_collections do |t|
      t.belongs_to :user, index: true
      t.belongs_to :song, index: true
      t.boolean :active

      t.timestamps
    end
  end
end
