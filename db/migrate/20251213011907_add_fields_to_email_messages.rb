class AddFieldsToEmailMessages < ActiveRecord::Migration[8.1]
  def change
    add_column :email_messages, :to_addresses, :text, array: true, default: []
    add_column :email_messages, :read, :boolean, default: false, null: false
    add_column :email_messages, :has_attachments, :boolean, default: false, null: false
  end
end
