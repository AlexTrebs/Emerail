Thread.new do
  loop do
    EmailAccount.find_each do |account|
      SyncEmailAccountJob.perform_async(account.id)
    end
    sleep 60 * 5 # every 5 minutes
  end
end
