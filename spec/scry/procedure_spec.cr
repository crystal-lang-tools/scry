require "../spec_helper"
require "../../src/scry/protocol/procedure"

module Scry

  describe Procedure do

    it "creates an initialization request" do
      procedure = Procedure.new(INITIALIZATION_EXAMPLE).parse
      procedure.is_a?(RemoteProcedureCall).should be_true
    end

    it "creates configuration change request" do
      procedure = Procedure.new(NOTIFICATION_EXAMPLE).parse
      procedure.is_a?(NotificationEvent).should be_true
    end

    it "creates a document opened request" do
      procedure = Procedure.new(DOC_OPEN_EXAMPLE).parse
      procedure.is_a?(NotificationEvent).should be_true
    end

    it "handles no-argument procedure calls" do
      procedure = Procedure.new(SHUTDOWN_EXAMPLE).parse
      procedure.is_a?(RemoteProcedureCallNoParams).should be_true
    end

  end

end