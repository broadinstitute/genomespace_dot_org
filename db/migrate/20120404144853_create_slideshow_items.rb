class CreateSlideshowItems < ActiveRecord::Migration
  def change
    create_table :slideshow_items do |t|
      t.string :title
      t.text :description
      t.string :url

      t.timestamps
    end
  end
end
