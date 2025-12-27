class AddLastSyncedAtToEmailAccounts < ActiveRecord::Migration[8.1]
  def change
    add_column :email_accounts, :last_synced_at, :datetime
  end
end
