require 'uri'

class AppConfig < Settingslogic

  def self.source_file_name
      File.join(Rails.root, "config", "application.yml")
  end
  source source_file_name
  namespace Rails.env

  def self.load!
    if no_config_file? 
      $stderr.puts <<-HELP
      need config/application.yml file
HELP
      Process.exit(1)
    end
    super
  end

  def self.no_config_file?
    !File.exists?(@source)
  end
  load!
end
