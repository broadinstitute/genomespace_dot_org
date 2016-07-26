class AddCreatedByToGuideSections < ActiveRecord::Migration
  def change
    add_column :guide_sections, :created_by, :string
  end
end
