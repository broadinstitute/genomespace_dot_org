class CreateHighlights < ActiveRecord::Migration
  def change
    create_table :highlights do |t|
      t.string :title
      t.text :content
      t.string :url
      t.boolean :dev
      t.string :created_by

      t.timestamps
    end
  end
end
