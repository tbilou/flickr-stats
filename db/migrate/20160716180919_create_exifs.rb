class CreateExifs < ActiveRecord::Migration
  def change
    #set | #name | #date | #url
    create_table :photos, id: false do |t|
      t.integer :photoId, null: false, :limit => 8
      t.string :camera
      t.string :make
      t.string :model
    end
    add_index :exifs, :photoId, unique: true
  end
end