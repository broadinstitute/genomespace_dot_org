class AddPriorityAndExpirationDateToSystemMessages < ActiveRecord::Migration
  def change
    add_column :system_messages, :priority, :string, :default => "general"
    add_column :system_messages, :expiration_date, :datetime
  end
end
