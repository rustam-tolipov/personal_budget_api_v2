source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.6"
gem 'active_model_serializers'
gem "bootsnap", require: false
gem 'cloudinary'
gem 'carrierwave'
gem 'devise'
gem 'devise-jwt'
gem 'dotenv-rails'
gem "image_processing", "~> 1.2"
gem "pg", "~> 1.1"
gem "puma", "~> 5.0"
gem "rails", "~> 7.0.4"
gem "rack-cors"
gem 'rswag'
gem 'rspec-rails'
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]


group :development, :test do
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem 'factory_bot_rails'
  gem 'faker'
end

group :development do
  gem 'listen', '~> 3.3'
  gem "spring"
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
end


gem "dockerfile-rails", ">= 1.4", :group => :development
