class CreateInvites < ActiveRecord::Migration
  def change
    create_table :invites do |t|
      t.string :email
      t.boolean :sent_invite

      t.timestamps
    end
  end
end
