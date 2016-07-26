class AddDeltaToHighlights < ActiveRecord::Migration
  def change
    add_column :highlights, :delta, :boolean
  end
end
