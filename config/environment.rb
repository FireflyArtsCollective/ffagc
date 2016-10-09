# Load the Rails application.
require File.expand_path('../application', __FILE__)

app_env_vars = File.join(Rails.root, 'config', 'initializers', 'smtp_secret.rb')
load(app_env_vars) if File.exists?(app_env_vars)

# Initialize the Rails application.
Rails.application.initialize!
