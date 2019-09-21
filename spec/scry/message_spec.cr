require "../spec_helper"

module Scry
  describe Message do
    it "creates an initialization request" do
      procedure = Message.from(INITIALIZATION_EXAMPLE)
      procedure.is_a?(LSP::Protocol::RequestMessage).should be_true
    end

    it "creates configuration change request" do
      procedure = Message.from(CONFIG_CHANGE_EXAMPLE)
      procedure.is_a?(LSP::Protocol::NotificationMessage).should be_true
    end

    it "creates a document opened request" do
      procedure = Message.from(DOC_OPEN_EXAMPLE)
      procedure.is_a?(LSP::Protocol::NotificationMessage).should be_true
    end

    it "handles no-argument procedure calls" do
      procedure = Message.from(SHUTDOWN_EXAMPLE)
      procedure.is_a?(LSP::Protocol::RequestMessage).should be_true
    end

    it "creates a didSave notification" do
      procedure = Message.from(DID_SAVE_EXAMPLE)
      procedure.is_a?(LSP::Protocol::NotificationMessage).should be_true
    end

    it "creates a didClose notification" do
      procedure = Message.from(DOC_CLOSE_EXAMPLE)
      procedure.is_a?(LSP::Protocol::NotificationMessage).should be_true
    end

    it "creates a initialized notification" do
      procedure = Message.from(INITIALIZED_EXAMPLE)
      procedure.is_a?(LSP::Protocol::NotificationMessage).should be_true
    end
  end
end
