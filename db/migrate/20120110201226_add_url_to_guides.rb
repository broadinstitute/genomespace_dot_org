class AddUrlToGuides < ActiveRecord::Migration
  def change
    add_column :guides, :url, :string
  end
end
