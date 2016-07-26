class AddDescAndCategoryToPages < ActiveRecord::Migration
  def change
    add_column :pages, :desc, :text
    add_column :pages, :category, :string
  end
end
