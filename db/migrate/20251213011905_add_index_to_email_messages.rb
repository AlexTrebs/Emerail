class AddIndexToEmailMessages < ActiveRecord::Migration[8.1]
  def change
    add_index :email_messages, :message_id, unique: true
  end
end
