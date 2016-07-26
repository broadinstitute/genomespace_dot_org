class CreateDeliverables < ActiveRecord::Migration
  def change
    create_table :deliverables do |t|
      t.string :description
      t.boolean :completed, :default => false

      t.timestamps
    end
  end
end
