require "../spec_helper"

module Scry
  describe Client do
    describe "#read" do
      it "reads request from io" do
        input = %(Content-Length: 5\r\n\r\nHello\r\n)
        io = IO::Memory.new(input)
        client = Client.new(io, STDOUT)

        request = client.read

        request.content.should eq("Hello")
      end
    end

    describe "#send_message" do
      it "sends a valid NotificationMessage to the Client io" do
        build_failure = BuildFailure.from_json(BUILD_ERROR_EXAMPLE)
        diagnostic = Protocol::Diagnostic.new(build_failure)

        params = Protocol::PublishDiagnosticsParams.new(
          "file:///Users/foo/project/some_file.cr",
          [diagnostic]
        )
        message = Protocol::NotificationMessage.new("textDocument/publishDiagnostics", params)

        io = IO::Memory.new
        client = Client.new(STDIN, io)
        client.send_message(message)
        io.to_s[0...19].should eq("Content-Length: 268")
      end

      it "sends a valid Initialize Reponse to the Client io" do
        message = Protocol::Initialize.new(32)

        io = IO::Memory.new
        client = Client.new(STDIN, io)
        client.send_message(message)
        io.to_s.should eq(%(Content-Length: 297\r\n\r\n{"jsonrpc":"2.0","id":32,"result":{"capabilities":{"textDocumentSync":1,"documentFormattingProvider":true,"definitionProvider":true,"documentSymbolProvider":true,"workspaceSymbolProvider":true,"completionProvider":{"resolveProvider":true,"triggerCharacters":[".","\\\"","/"]},"hoverProvider":true}}}))
      end

      it "sends a valid ResponseMessage to the Client io" do
        result = [] of Protocol::SymbolInformation
        message = Protocol::ResponseMessage.new(1, result)

        io = IO::Memory.new
        client = Client.new(STDIN, io)
        client.send_message(message)
        io.to_s.should eq(%(Content-Length: 36\r\n\r\n{\"jsonrpc\":\"2.0\",\"id\":1,\"result\":[]}))
      end

      it "sends multiple ClientMessages" do
        messages = [] of Client::ClientMessage
        messages << Protocol::NotificationMessage.new("fake1", Protocol::VoidParams.from_json("{}"))
        messages << Protocol::NotificationMessage.new("fake2", Protocol::VoidParams.from_json("{}"))

        io = IO::Memory.new
        client = Client.new(STDIN, io)
        client.send_message(messages)
        messages.to_json
        io.to_s.should contain("fake1")
        io.to_s.should contain("fake2")
      end
    end
  end
end
