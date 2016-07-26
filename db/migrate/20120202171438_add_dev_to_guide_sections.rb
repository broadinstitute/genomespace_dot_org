class AddDevToGuideSections < ActiveRecord::Migration
  def change
    add_column :guide_sections, :dev, :boolean, :default => false
  end
end
