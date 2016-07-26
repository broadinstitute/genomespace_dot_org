class AddIdentifierAndTechToDeliverables < ActiveRecord::Migration
  def change
    add_column :deliverables, :identifier, :string
    add_column :deliverables, :tech, :boolean
  end
end
