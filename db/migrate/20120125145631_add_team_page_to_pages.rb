class AddTeamPageToPages < ActiveRecord::Migration
  def change
    add_column :pages, :team_page, :boolean, :default => false
  end
end
