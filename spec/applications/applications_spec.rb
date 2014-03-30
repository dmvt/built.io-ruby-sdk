require "applications/stub"

describe Built::Application do
  before(:each) do
    ApplicationsStub.stub
  end

  it "should get application" do
    response = Built::Application.get

    expect(response).to be_an_instance_of Built::Application
    response.api_key.should eq(Built::SPEC_APP[:application_api_key])
  end
end