require "webmock"

class ClassesStub
  class << self
    include WebMock::API

    @@classes = JSON.parse(IO.read("spec/classes/classes.json"))

    def stub
      stub_single_class
      stub_all_classes
    end

    def stub_single_class
      class_uid = "built_io_application_user_role"
      class_url = API_URI + [Built::Class.uri, class_uid].join("/")
      
      stub_request(:get, class_url)
        .with(:headers => {
          "application_api_key" => SPEC_APP[:application_api_key]
        })
        .to_return(
          :body => JSON.dump({"class" => @@classes["classes"].find{|c| c["uid"] == class_uid}}),
          :headers => {
            "Content-Type" => "application/json"
          }
        )
    end

    def stub_all_classes
      class_url = API_URI + Built::Class.uri

      stub_request(:get, class_url)
        .with(:headers => {
          "application_api_key" => SPEC_APP[:application_api_key]
        })
        .to_return(
          :body => JSON.dump(@@classes),
          :headers => {
            'Content-Type' => 'application/json'
          }
        )
    end
  end
end
