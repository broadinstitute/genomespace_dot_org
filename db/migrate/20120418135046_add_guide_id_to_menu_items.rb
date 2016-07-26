class AddGuideIdToMenuItems < ActiveRecord::Migration
  def change
    add_column :menu_items, :guide_id, :integer
  end
end
