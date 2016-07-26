class AddQuarterToDeliverables < ActiveRecord::Migration
  def change
    add_column :deliverables, :quarter, :string
  end
end
