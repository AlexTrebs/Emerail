class SyncOlderEmailsJob
  include Sidekiq::Job

  def perform(account_id, start_date_string, end_date_string)
    account = EmailAccount.find(account_id)
    start_date = Date.parse(start_date_string)
    end_date = Date.parse(end_date_string)

    # Sync emails between start and end date, newest first, limited to 50
    EmailSyncService.new(account).sync!(start_date: start_date, end_date: end_date, limit: 50)
  end
end
