require 'resque'
Dir[File.join(Rails.root, 'app','jobs', '*.rb')].each { |file| require file }

