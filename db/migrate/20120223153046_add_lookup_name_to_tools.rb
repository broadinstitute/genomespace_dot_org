class AddLookupNameToTools < ActiveRecord::Migration
  def change
    add_column :tools, :lookup_name, :string
  end
end
