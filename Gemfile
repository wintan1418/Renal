source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.4"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem "tailwindcss-rails"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Authentication & Authorization
gem "devise", "~> 4.9"
gem "pundit", "~> 2.4"

# Phone number validation
gem "phonelib", "~> 0.9"

# Search
gem "pg_search", "~> 2.3"

# Pagination
gem "pagy", "~> 9.3"

# Currency handling (NGN)
gem "money-rails", "~> 3.0"

# Audit trail
gem "audited", "~> 5.7"

# Calendar views
gem "simple_calendar", "~> 3.1"

# Charts & analytics
gem "chartkick", "~> 5.1"
gem "groupdate", "~> 6.5"

# HTTP client (Paystack, Termii SMS)
gem "faraday", "~> 2.12"

# AI — unified LLM interface (Gemini + OpenAI/ChatGPT)
gem "ruby_llm", "~> 1.16"

# PDF generation
gem "prawn", "~> 2.5"
gem "prawn-table", "~> 0.2"
gem "matrix", "~> 0.4"

# Image processing for Active Storage variants
gem "image_processing", "~> 1.13"

# Cloudinary — Active Storage service for production media (reads CLOUDINARY_URL)
gem "cloudinary", "~> 2.4"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false


group :development, :test do
  gem "dotenv-rails" # loads .env so local API keys (Gemini, OpenRouter, etc.) are available
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem "factory_bot_rails", "~> 6.4"
  gem "faker", "~> 3.4"
  gem "shoulda-matchers", "~> 6.2"
end

group :development do
  gem "web-console"
  gem "letter_opener", "~> 1.10"
  gem "bullet", "~> 8.0"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "webmock", "~> 3.23"
  gem "simplecov", require: false
end
