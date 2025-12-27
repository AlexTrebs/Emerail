namespace :email do
  task sync: :environment do
    EmailAccount.find_each do |acc|
      EmailSyncService.new(acc).sync!
    end
  end
end
