class AddCreatedByToDocs < ActiveRecord::Migration
  def change
    add_column :docs, :created_by, :string
  end
end
