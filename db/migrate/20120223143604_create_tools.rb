class CreateTools < ActiveRecord::Migration
  def change
    create_table :tools do |t|
      t.string :name
      t.text :desc
			t.boolean :delta, :default => true, :null => false
			
      t.timestamps
    end
  end
end
