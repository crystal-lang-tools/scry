require "../spec_helper"
require "../../src/scry/protocol/message"

module Scry

  describe Message do

    it "creates an initialization request" do
      procedure = Message.new(INITIALIZATION_EXAMPLE).parse
      procedure.is_a?(RequestMessage).should be_true
    end

    it "creates configuration change request" do
      procedure = Message.new(CONFIG_CHANGE_EXAMPLE).parse
      procedure.is_a?(NotificationMessage).should be_true
    end

    it "creates a document opened request" do
      procedure = Message.new(DOC_OPEN_EXAMPLE).parse
      procedure.is_a?(NotificationMessage).should be_true
    end

    it "handles no-argument procedure calls" do
      procedure = Message.new(SHUTDOWN_EXAMPLE).parse
      procedure.is_a?(RequestMessageNoParams).should be_true
    end

  end

end
