class AddAttachmentImageToSlideshowItem < ActiveRecord::Migration
  def self.up
    add_column :slideshow_items, :image_file_name, :string
    add_column :slideshow_items, :image_content_type, :string
    add_column :slideshow_items, :image_file_size, :integer
    add_column :slideshow_items, :image_updated_at, :datetime
  end

  def self.down
    remove_column :slideshow_items, :image_file_name
    remove_column :slideshow_items, :image_content_type
    remove_column :slideshow_items, :image_file_size
    remove_column :slideshow_items, :image_updated_at
  end
end
