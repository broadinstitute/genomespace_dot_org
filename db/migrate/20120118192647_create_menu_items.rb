class CreateMenuItems < ActiveRecord::Migration
  def change
    create_table :menu_items do |t|
      t.integer :page_id
      t.integer :display_order
      t.string :category

      t.timestamps
    end
  end
end
