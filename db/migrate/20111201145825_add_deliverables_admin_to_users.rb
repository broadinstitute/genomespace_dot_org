class AddDeliverablesAdminToUsers < ActiveRecord::Migration
  def change
    add_column :users, :deliverables_admin, :boolean, :default => false
    add_column :users, :cms_admin, :boolean, :default => false
  end
end
