class CreatePhotos < ActiveRecord::Migration
  def change
    #set | #name | #date | #url
    create_table :photos do |t|
      t.string :set
      t.string :name
      t.datetime :date
      t.string :url
    end
  end
end