class AddDeprecatedToDocs < ActiveRecord::Migration
  def change
    add_column :docs, :deprecated, :boolean, :default => false
  end
end
