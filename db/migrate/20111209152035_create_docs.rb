class CreateDocs < ActiveRecord::Migration
  def change
    create_table :docs do |t|
      t.string :component
      t.integer :maj_version
      t.integer :min_version
      t.string :dev_stage
      t.string :url
      t.text :contents

      t.timestamps
    end
  end
end
