class CreateHelpLinks < ActiveRecord::Migration
  def change
    create_table :help_links do |t|
      t.integer :tool_id
      t.string :title
      t.string :url

      t.timestamps
    end
  end
end
