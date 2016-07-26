class AddPublishedToGuideSections < ActiveRecord::Migration
  def change
    add_column :guide_sections, :published, :boolean, :default => true
  end
end
