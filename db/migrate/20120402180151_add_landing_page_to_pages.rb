class AddLandingPageToPages < ActiveRecord::Migration
  def change
    add_column :pages, :landing_page, :boolean, :default => false
  end
end
