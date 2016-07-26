class AddCreatedByToPages < ActiveRecord::Migration
  def change
    add_column :pages, :created_by, :string
  end
end
