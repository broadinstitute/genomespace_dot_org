class AddDeltaToDeliverables < ActiveRecord::Migration
  def change
    add_column :deliverables, :delta, :boolean, :default => true, :null => false
  end
end
