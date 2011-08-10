# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Isport::Application.initialize!

Sass::Plugin.options[:template_location] = [['./public/stylesheets/sass', './public/stylesheets/css']]

