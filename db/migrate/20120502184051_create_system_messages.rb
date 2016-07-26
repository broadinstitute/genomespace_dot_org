class CreateSystemMessages < ActiveRecord::Migration
  def change
    create_table :system_messages do |t|
      t.string :url
      t.text :content
      t.integer :lock_version, :default => 0

      t.timestamps
    end
  end
end
