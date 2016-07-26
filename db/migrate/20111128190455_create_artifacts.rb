class CreateArtifacts < ActiveRecord::Migration
  def change
    create_table :artifacts do |t|
      t.integer :deliverable_id
      t.text :contents

      t.timestamps
    end
  end
end
