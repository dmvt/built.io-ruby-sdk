require "webmock/rspec"
require "built"

RSpec.configure do |c|
  Built::SPEC_APP = {
    application_api_key:  "specapikey",
    master_key:           "specmasterkey"
  }

  c.before do
    Built.init :application_api_key => Built::SPEC_APP[:application_api_key]
  end
end
