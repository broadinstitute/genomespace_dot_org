class AddLockVersionToAllModels < ActiveRecord::Migration
  def change
  	add_column :highlights, :lock_version, :integer, :default => 0
  	add_column :pages, :lock_version, :integer, :default => 0
  	add_column :deliverables, :lock_version, :integer, :default => 0
  	add_column :docs, :lock_version, :integer, :default => 0
  	add_column :guide_sections, :lock_version, :integer, :default => 0
  	add_column :guides, :lock_version, :integer, :default => 0
  	add_column :tools, :lock_version, :integer, :default => 0
  end
end
