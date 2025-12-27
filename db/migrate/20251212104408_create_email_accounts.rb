class CreateEmailAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :email_accounts do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :provider
      t.string :imap_host
      t.integer :imap_port
      t.boolean :imap_ssl
      t.string :username
      t.string :password_digest

      t.timestamps
    end
  end
end
