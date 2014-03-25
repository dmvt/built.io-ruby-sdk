require "classes/stub"

describe Built::Class do
  before(:each) do
    ClassesStub.stub

    Built.init :application_api_key => SPEC_APP[:application_api_key]
  end

  it "should get list of classes" do
    response = Built::Class.get_all

    response.length.should eq(3)
    expect(response[0]).to be_an_instance_of Built::Class
  end

  it "should get a single class" do
    response = Built::Class.get("built_io_application_user_role")

    expect(response).to be_an_instance_of Built::Class
    response.uid.should eq("built_io_application_user_role")
    response.inbuilt_class?.should be_true
  end
end