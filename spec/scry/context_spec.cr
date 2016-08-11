require "../spec_helper"
require "../../src/scry/context"


module Scry

  describe Context do

    it "dispatches commands" do
      context = Context.new

      procedure = Message.new(INITIALIZATION_EXAMPLE).parse
      result = context.dispatch(procedure)
      result.is_a?(ServerCapabilities).should be_true

      procedure = Message.new(CONFIG_CHANGE_EXAMPLE).parse
      context.dispatch(procedure)

      procedure = Message.new(DOC_OPEN_EXAMPLE).parse
      context.dispatch(procedure)

      procedure = Message.new(DOC_CHANGE_EXAMPLE).parse
      context.dispatch(procedure)

      procedure = Message.new(WATCHED_FILE_CHANGED_EXAMPLE).parse
      context.dispatch(procedure)

      procedure = Message.new(WATCHED_FILE_DELETED_EXAMPLE).parse
      result = context.dispatch(procedure)
      result.to_json.should eq(%([{"jsonrpc":"2.0","method":"textDocument/publishDiagnostics","params":{"uri":"file://#{SOME_FILE_PATH}","diagnostics":[]}}]))
    end


  end

end
