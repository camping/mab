# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require_relative '../config/environment'
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!
