require 'active_support/all'
require 'webrat'

RSpec.configure do |config|
  config.mock_with :rspec
  config.include(Webrat::Matchers)
end
