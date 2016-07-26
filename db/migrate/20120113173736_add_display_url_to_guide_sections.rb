class AddDisplayUrlToGuideSections < ActiveRecord::Migration
  def change
    add_column :guide_sections, :display_url, :string
  end
end
