class AddPublishedToTools < ActiveRecord::Migration
  def change
    add_column :tools, :published, :boolean, :default => true
  end
end
