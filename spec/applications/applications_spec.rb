require "applications/stub"

describe Built::Class do
  before(:each) do
    ApplicationsStub.stub

    Built.init :application_api_key => SPEC_APP[:application_api_key]
  end

  it "should get application" do
    response = Built::Application.get

    expect(response).to be_an_instance_of Built::Application
    response.api_key.should eq(SPEC_APP[:application_api_key])
  end
end