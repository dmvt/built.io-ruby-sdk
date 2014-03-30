require "objects/stub"

describe Built::Object do
  it "should sync object with a valid uid" do
    ObjectsStub.stub_sync

    obj = Built::Object.new("test", "test").sync
    obj.version.should eq(0)
    obj.uid.should eq("test")
    obj.created_at.class.should eq(DateTime)
    obj.updated_at.class.should eq(DateTime)
    obj.is_new?.should be_false
    obj.is_published?.should be_true

    obj.ACL.class.should eq(Built::ACL)
    obj.ACL.can_update?.should be_true
    obj.ACL.can_delete?.should be_true
  end

  it "should create a new object" do
    ObjectsStub.stub_create

    obj = Built::Object.new("test")
    obj["test"] = "test"
    obj.save

    obj["test"].should eq("test")
    obj.version.should eq(0)
  end

  it "should update objects" do
    ObjectsStub.stub_update

    obj = Built::Object.new("test", "test")
    obj["test"] = "hello"
    obj.save

    obj["test"].should eq("hello")
    obj.version.should eq(1)
  end

  it "should delete objects" do
    ObjectsStub.stub_delete

    obj = Built::Object.new("test", "test")
    obj.destroy

    obj.uid.should be_nil
    obj.should be_empty
  end

  it "should be able to add tags" do
    ObjectsStub.stub_tags

    obj = Built::Object.new("test", "test")
    obj.add_tags(["hey", "wassup"])
    obj.save

    obj.tags.should eq(["hey", "wassup"])
  end

  it "should PUSH value into array" do
    ObjectsStub.stub_push

    obj = Built::Object.new("test", "test")
    obj.push_value("test", "myval", 1)
    obj.save

    obj["test"].should eq(["one", "myval", "two"])
  end

  it "should PULL value from array" do
    ObjectsStub.stub_pull

    obj = Built::Object.new("test", "test")
    obj.pull_value("test", "myval")
    obj.save

    obj["test"].should eq(["one", "two"])
  end

  it "should PULL index from array" do
    ObjectsStub.stub_pull_index

    obj = Built::Object.new("test", "test")
    obj.pull_value("test", nil, 1)
    obj.save

    obj["test"].should eq(["one", "two"])
  end

  it "should UPDATE index in array" do
    ObjectsStub.stub_update_index

    obj = Built::Object.new("test", "test")
    obj.update_value("test", "hello", 1)
    obj.save

    obj["test"].should eq(["one", "hello", "two"])
  end
end