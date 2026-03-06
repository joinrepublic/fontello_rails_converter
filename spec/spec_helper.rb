require 'rubygems'
require 'bundler/setup'
require 'simplecov'

SimpleCov.start do
  minimum_coverage line: 90
  add_filter '/spec/'
end

require 'fontello_rails_converter'

RSpec.configure do |config|
  config.filter_run_when_matching :focus
  config.raise_errors_for_deprecations!

  config.order = :random
end
