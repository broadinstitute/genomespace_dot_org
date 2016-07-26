class AddDeltaToGuides < ActiveRecord::Migration
  def change
    add_column :guides, :delta, :boolean, :default => true, :null => false
  end
end
