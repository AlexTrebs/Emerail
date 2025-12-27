class SyncAllAccountsJob
  include Sidekiq::Job

  def perform
    EmailAccount.find_each do |account|
      SyncEmailAccountJob.perform_async(account.id)
    end
  end
end
