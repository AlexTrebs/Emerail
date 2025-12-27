class ChangePasswordDigestToPasswordOnEmailAccounts < ActiveRecord::Migration[8.1]
  def change
    remove_column :email_accounts, :password_digest, :string
    add_column :email_accounts, :password, :string
  end
end
