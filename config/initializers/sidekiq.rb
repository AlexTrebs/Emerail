require 'sidekiq/cron'

# Only load cron schedule when Sidekiq server is running
# This prevents Redis connection errors during Rails initialization
Sidekiq.configure_server do |config|
  schedule_file = Rails.root.join("config", "sidekiq_schedule.yml")

  if File.exist?(schedule_file)
    Sidekiq::Cron::Job.load_from_hash! YAML.load_file(schedule_file)
  end
end
