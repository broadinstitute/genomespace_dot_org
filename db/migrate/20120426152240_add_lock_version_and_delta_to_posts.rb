class AddLockVersionAndDeltaToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :lock_version, :integer
    add_column :posts, :delta, :boolean, :default => true, :null => false
  end
end
