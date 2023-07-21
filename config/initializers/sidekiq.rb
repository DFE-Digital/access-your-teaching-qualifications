# frozen_string_literal: true

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1") }
  Sidekiq.options[:fetch] = Sidekiq::QueuePause::PausingFetch.new(
    Sidekiq.options
  )
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1") }
end

Sidekiq::QueuePause.pause(DfE::Analytics.config.queue) unless Rails.env.test?
