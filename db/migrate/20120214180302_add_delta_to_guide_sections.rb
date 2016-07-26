class AddDeltaToGuideSections < ActiveRecord::Migration
  def change
    add_column :guide_sections, :delta, :boolean, :default => true, :null => false
  end
end
