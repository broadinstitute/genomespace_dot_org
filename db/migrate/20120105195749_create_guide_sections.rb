class CreateGuideSections < ActiveRecord::Migration
  def change
    create_table :guide_sections do |t|
      t.integer :guide_id
      t.string :title
      t.integer :display_order
      t.text :content
      t.integer :parent_id

      t.timestamps
    end
  end
end
