class CreateServerProperties < ActiveRecord::Migration
  def change
    create_table :server_properties do |t|
      t.text :content

      t.timestamps
    end
  end
end
