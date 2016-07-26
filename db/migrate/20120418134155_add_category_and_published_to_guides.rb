class AddCategoryAndPublishedToGuides < ActiveRecord::Migration
  def change
    add_column :guides, :category, :string
    add_column :guides, :published, :boolean, :default => true
  end
end
