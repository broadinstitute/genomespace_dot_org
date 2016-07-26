class AddDisplayOrderToSlideshowItems < ActiveRecord::Migration
  def change
    add_column :slideshow_items, :display_order, :integer
  end
end
