class AddEmailedToInvites < ActiveRecord::Migration
  def change
    add_column :invites, :emailed, :datetime
  end
end
