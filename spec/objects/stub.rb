require "webmock"

class ObjectsStub
  class << self
    include WebMock::API
    

    def stub_sync
      obj_url = Built::API_URI + Built::Object.uri("test") + "/test"
      response = JSON.parse(IO.read("spec/objects/responses/get_one_object.json"))

      stub_request(:get, obj_url)
        .with(:headers => {
          "application_api_key" => Built::SPEC_APP[:application_api_key]
        })
        .to_return(
          :body => JSON.dump(response),
          :headers => {
            "Content-Type" => "application/json"
          }
        )
    end

    def stub_create
      obj_url = Built::API_URI + Built::Object.uri("test")
      response = JSON.parse(IO.read("spec/objects/responses/create_object.json"))

      stub_request(:post, obj_url)
        .with(:headers => {
          "application_api_key" => Built::SPEC_APP[:application_api_key]
        }, :body => {
          "object" => {"test" => "test"}
        })
        .to_return(
          :body => JSON.dump(response),
          :headers => {
            "Content-Type" => "application/json"
          }
        )
    end

    def stub_update
      obj_url = Built::API_URI + Built::Object.uri("test") + "/test"
      response = JSON.parse(IO.read("spec/objects/responses/update_object.json"))

      stub_request(:put, obj_url)
        .with(:headers => {
          "application_api_key" => Built::SPEC_APP[:application_api_key]
        }, :body => {
          "object" => {"test" => "hello"}
        })
        .to_return(
          :body => JSON.dump(response),
          :headers => {
            "Content-Type" => "application/json"
          }
        )
    end

    def stub_delete
      obj_url = Built::API_URI + Built::Object.uri("test") + "/test"
      response = JSON.parse(IO.read("spec/objects/responses/delete_object.json"))

      stub_request(:delete, obj_url)
        .with(:headers => {
          "application_api_key" => Built::SPEC_APP[:application_api_key]
        })
        .to_return(
          :body => JSON.dump(response),
          :headers => {
            "Content-Type" => "application/json"
          }
        )
    end

    def stub_tags
      obj_url = Built::API_URI + Built::Object.uri("test") + "/test"
      response = JSON.parse(IO.read("spec/objects/responses/object_tags.json"))

      stub_request(:put, obj_url)
        .with(:headers => {
          "application_api_key" => Built::SPEC_APP[:application_api_key]
        }, :body => {
          "object" => {"tags" => ["hey", "wassup"]}
        })
        .to_return(
          :body => JSON.dump(response),
          :headers => {
            "Content-Type" => "application/json"
          }
        )
    end

    def stub_push
      obj_url = Built::API_URI + Built::Object.uri("test") + "/test"
      response = JSON.parse(IO.read("spec/objects/responses/push_multiple.json"))

      stub_request(:put, obj_url)
        .with(:headers => {
          "application_api_key" => Built::SPEC_APP[:application_api_key]
        }, :body => {
          "object" => {
            "test" => {
              "PUSH" => {
                "data" => ["myval"],
                "index" => 1
              }
            }
          }
        })
        .to_return(
          :body => JSON.dump(response),
          :headers => {
            "Content-Type" => "application/json"
          }
        )
    end

    def stub_pull
      obj_url = Built::API_URI + Built::Object.uri("test") + "/test"
      response = JSON.parse(IO.read("spec/objects/responses/pull_multiple_value.json"))

      stub_request(:put, obj_url)
        .with(:headers => {
          "application_api_key" => Built::SPEC_APP[:application_api_key]
        }, :body => {
          "object" => {
            "test" => {
              "PULL" => {
                "data" => ["myval"]
              }
            }
          }
        })
        .to_return(
          :body => JSON.dump(response),
          :headers => {
            "Content-Type" => "application/json"
          }
        )
    end

    def stub_pull_index
      obj_url = Built::API_URI + Built::Object.uri("test") + "/test"
      response = JSON.parse(IO.read("spec/objects/responses/pull_multiple_index.json"))

      stub_request(:put, obj_url)
        .with(:headers => {
          "application_api_key" => Built::SPEC_APP[:application_api_key]
        }, :body => {
          "object" => {
            "test" => {
              "PULL" => {
                "index" => 1
              }
            }
          }
        })
        .to_return(
          :body => JSON.dump(response),
          :headers => {
            "Content-Type" => "application/json"
          }
        )
    end

    def stub_update_index
      obj_url = Built::API_URI + Built::Object.uri("test") + "/test"
      response = JSON.parse(IO.read("spec/objects/responses/update_multiple_index.json"))

      stub_request(:put, obj_url)
        .with(:headers => {
          "application_api_key" => Built::SPEC_APP[:application_api_key]
        }, :body => {
          "object" => {
            "test" => {
              "UPDATE" => {
                "data" => "hello",
                "index" => 1
              }
            }
          }
        })
        .to_return(
          :body => JSON.dump(response),
          :headers => {
            "Content-Type" => "application/json"
          }
        )
    end
  end
end