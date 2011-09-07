require 'resque'
Dir[File.join(Rails.root, 'app','jobs', '*.rb')].each { |file| require file }
unless defined?(RESQUE_LOGGER)
  RESQUE_LOGGER =
ActiveSupport::BufferedLogger.new("#{Rails.root}/log/resque.log")
  RESQUE_LOGGER.auto_flushing = true
end


