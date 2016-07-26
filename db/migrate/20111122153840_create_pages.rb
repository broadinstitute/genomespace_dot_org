class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :title
      t.string :url
      t.text :content
      t.boolean :home_page, :default => false
      t.boolean :published, :default => true

      t.timestamps
    end
  end
end
