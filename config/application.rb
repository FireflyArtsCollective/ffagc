require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'log4r'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)


module Ffagc
  Logger = Log4r::Logger.new self.name
  Logger.outputters = Log4r::Outputter.stderr
  Logger.level=Log4r::INFO

  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.autoload_paths << Rails.root.join('lib')
    config.autoload_paths += Dir["#{config.root}/lib/pdf"]

    # Disable "field_with_errors" magic
    config.action_view.field_error_proc = Proc.new { |html_tag, instance|
      html_tag
    }

    # The year that the event will take place
    config.event_year = "2021"
    # The timezone for the event, used to calculate submission and voting
    # deadlines.
    config.event_timezone = "America/New_York"
  end
end
