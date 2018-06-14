require "../spec_helper"

module Scry
  describe Client do
    describe "#send_message" do
      it "sends a valid NotificationMessage to the Client io" do
        build_failure = BuildFailure.from_json(BUILD_ERROR_EXAMPLE)
        diagnostic = Diagnostic.new(build_failure)

        params = PublishDiagnosticsParams.new(
          "file:///Users/foo/project/some_file.cr",
          [diagnostic]
        )
        message = NotificationMessage.new("textDocument/publishDiagnostics", params)

        io = IO::Memory.new
        client = Client.new(io)
        client.send_message(message)
        io.to_s[0...19].should eq("Content-Length: 268")
      end

      it "sends a valid Initialize Reponse to the Client io" do
        message = Initialize.new(32)

        io = IO::Memory.new
        client = Client.new(io)
        client.send_message(message)
        io.to_s.should eq(%(Content-Length: 297\r\n\r\n{"jsonrpc":"2.0","id":32,"result":{"capabilities":{"textDocumentSync":1,"documentFormattingProvider":true,"definitionProvider":true,"documentSymbolProvider":true,"workspaceSymbolProvider":true,"completionProvider":{"resolveProvider":true,"triggerCharacters":[".","\\\"","/"]},"hoverProvider":true}}}))
      end

      it "sends a valid ResponseMessage to the Client io" do
        result = [] of SymbolInformation
        message = ResponseMessage.new(1, result)

        io = IO::Memory.new
        client = Client.new(io)
        client.send_message(message)
        io.to_s.should eq(%(Content-Length: 36\r\n\r\n{\"jsonrpc\":\"2.0\",\"id\":1,\"result\":[]}))
      end

      it "sends multiple ClientMessages" do
        messages = [] of Client::ClientMessage
        messages << NotificationMessage.new("fake1", VoidParams.from_json("{}"))
        messages << NotificationMessage.new("fake2", VoidParams.from_json("{}"))

        io = IO::Memory.new
        client = Client.new(io)
        client.send_message(messages)
        messages.to_json
        io.to_s.should contain("fake1")
        io.to_s.should contain("fake2")
      end
    end
  end
end
