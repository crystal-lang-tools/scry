require "../spec_helper"

module Scry
  describe Message do
    it "creates an initialization request" do
      procedure = Message.new(INITIALIZATION_EXAMPLE).parse
      procedure.is_a?(Protocol::RequestMessage).should be_true
    end

    it "creates configuration change request" do
      procedure = Message.new(CONFIG_CHANGE_EXAMPLE).parse
      procedure.is_a?(Protocol::NotificationMessage).should be_true
    end

    it "creates a document opened request" do
      procedure = Message.new(DOC_OPEN_EXAMPLE).parse
      procedure.is_a?(Protocol::NotificationMessage).should be_true
    end

    it "handles no-argument procedure calls" do
      procedure = Message.new(SHUTDOWN_EXAMPLE).parse
      procedure.is_a?(Protocol::RequestMessage).should be_true
    end

    it "creates a didSave notification" do
      procedure = Message.new(DID_SAVE_EXAMPLE).parse
      procedure.is_a?(Protocol::NotificationMessage).should be_true
    end

    it "creates a didClose notification" do
      procedure = Message.new(DOC_CLOSE_EXAMPLE).parse
      procedure.is_a?(Protocol::NotificationMessage).should be_true
    end

    it "creates a initialized notification" do
      procedure = Message.new(INITIALIZED_EXAMPLE).parse
      procedure.is_a?(Protocol::NotificationMessage).should be_true
    end
  end
end
