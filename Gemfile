# frozen_string_literal: true

source "https://rubygems.org"

ruby "3.3.1"

gem "postgresql"
gem "rails", "~> 7.1.3", ">= 7.1.3.2"
gem "sprockets-rails"

gem "puma", ">= 5.0"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[windows jruby]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri windows]
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
  gem "foreman"
  gem "pry-rails"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
end

gem "rubocop", "~> 1.63"
gem "tailwindcss-rails", "~> 2.5"

gem "devise", "~> 4.9"
gem "omniauth-square", git: "https://github.com/dja/omniauth-square.git"
gem "omniauth-google-oauth2"
gem "omniauth-rails_csrf_protection"
gem "square.rb", "~> 39"
gem "csv"
