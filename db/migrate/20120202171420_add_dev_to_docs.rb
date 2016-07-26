class AddDevToDocs < ActiveRecord::Migration
  def change
    add_column :docs, :dev, :boolean, :default => false
  end
end
