class CreatePhotos < ActiveRecord::Migration
  def change
    #set | #name | #date | #url
    create_table :photos, id: false do |t|
      t.integer :photoId, null: false, :limit => 8
      t.string :set
      t.string :name
      t.datetime :date
      t.string :url
    end
    add_index :photos, :photoId, unique: true
  end
end