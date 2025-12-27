class AddHtmlBodyToEmailMessages < ActiveRecord::Migration[8.1]
  def change
    add_column :email_messages, :html_body, :text
  end
end
