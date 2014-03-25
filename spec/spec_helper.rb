require 'webmock/rspec'

RSpec.configure do |c|
  SPEC_APP = {
    application_api_key:  "specapikey",
    master_key:           "specmasterkey"
  }

  c.before do
  end
end
