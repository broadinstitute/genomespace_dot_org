class AddDeltaToPages < ActiveRecord::Migration
  def change
    add_column :pages, :delta, :boolean, :default => true, :null => false
  end
end
