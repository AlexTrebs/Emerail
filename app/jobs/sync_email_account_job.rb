class SyncEmailAccountJob
  include Sidekiq::Job

  def perform(account_id)
    account = EmailAccount.find(account_id)
    EmailSyncService.new(account).sync!
  end
end
