require "webmock"

class ApplicationsStub
  class << self
    include WebMock::API

    @@app = JSON.parse(IO.read("spec/applications/application.json"))

    def stub
      stub_single_app
    end

    def stub_single_app
      app_url = API_URI + Built::Application.uri
      
      stub_request(:get, app_url)
        .with(:headers => {
          "application_api_key" => SPEC_APP[:application_api_key]
        })
        .to_return(
          :body => JSON.dump(@@app),
          :headers => {
            "Content-Type" => "application/json"
          }
        )
    end
  end
end
