source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails'
gem 'webrick', '~> 1.7'
# Define Abilites of Models in one place
gem 'cancancan'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
gem "sprockets-rails"
gem 'sprockets'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'execjs'

# Use SCSS for stylesheets
gem 'sassc-rails'
gem 'bootstrap-sass'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use jquery as the JavaScript library
gem 'jquery-rails'

# Forms
gem 'simple_form'
gem 'judge'
gem 'country_select'

# File upload
gem 'carrierwave'
gem 'file_validators' # file upload size validation

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'
gem 'json', '~> 2.6', '>= 2.6.2'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc'

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# pdf generation
gem 'prawn'
gem 'pdf-inspector', require: 'pdf/inspector'

# logging
gem 'log4r'

# Load ENV from a `.env` file`
gem 'dotenv'
gem 'dotenv-rails'

# Automatically create text emails from HTML ones
gem 'premailer-rails'

gem 'csv'

group :test, :development do
  gem 'pry'

  # Create fake models with data
  gem 'factory_bot_rails'
  gem 'faker'

  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'guard-rspec'

  # Freeze / travel time in tests
  gem 'timecop'

  # Lint code
  gem 'rubocop', require: false
  # Check for gems with CVEs
  gem 'bundler-audit', require: false
end

group :test do
  gem 'rspec_junit_formatter'
  gem 'rails-controller-testing'
end

group :development do
  gem 'letter_opener'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  #gem 'spring'
end
