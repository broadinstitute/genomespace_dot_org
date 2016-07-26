class AddDevToPages < ActiveRecord::Migration
  def change
    add_column :pages, :dev, :boolean, :default => false
  end
end
