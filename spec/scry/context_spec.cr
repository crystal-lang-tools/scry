require "../spec_helper"

module Scry
  describe Context do
    it "dispatches commands" do
      context = Context.new

      procedure = Message.from(INITIALIZATION_EXAMPLE)
      result = context.dispatch(procedure)
      result.is_a?(Protocol::Initialize).should be_true

      procedure = Message.from(CONFIG_CHANGE_EXAMPLE)
      context.dispatch(procedure)

      procedure = Message.from(DOC_OPEN_EXAMPLE)
      context.dispatch(procedure)

      procedure = Message.from(DOC_CHANGE_EXAMPLE)
      context.dispatch(procedure)

      procedure = Message.from(WATCHED_FILE_CHANGED_EXAMPLE)
      context.dispatch(procedure)

      procedure = Message.from(WATCHED_FILE_DELETED_EXAMPLE)
      result = context.dispatch(procedure)
      result.to_json.should eq(%([[{"jsonrpc":"2.0","method":"textDocument/publishDiagnostics","params":{"uri":"file://#{SOME_FILE_PATH}","diagnostics":[]}}]]))
    end
  end
end
