require "../spec_helper"

module Scry
  describe Response do
    it "doesn't write if result is Nil" do
      results = [] of Initialize | ResponseMessage | NotificationMessage | Nil
      results << nil

      io = IO::Memory.new
      response = Response.new(results)
      response.write(io)
      io.to_s.should eq("")
    end

    it "responds with published diagnostics" do
      build_failure = BuildFailure.from_json(BUILD_ERROR_EXAMPLE)
      diagnostic = Diagnostic.new(build_failure)

      results = [] of Initialize | ResponseMessage | NotificationMessage | Nil
      params = PublishDiagnosticsParams.new(
        "file:///Users/foo/project/some_file.cr",
        [diagnostic]
      )
      results << NotificationMessage.new("textDocument/publishDiagnostics", params)

      io = IO::Memory.new
      response = Response.new(results)
      response.write(io)
      io.to_s[0...19].should eq("Content-Length: 278")
    end

    it "responds with server capabilities" do
      server_cap = Initialize.new(32)

      results = [] of Initialize | ResponseMessage | NotificationMessage | Nil
      results << server_cap

      io = IO::Memory.new
      response = Response.new(results)
      response.write(io)
      io.to_s.should eq(%(Content-Length: 236\r\n\r\n{"jsonrpc":"2.0","id":32,"result":{"capabilities":{"textDocumentSync":1,"documentFormattingProvider":true,"definitionProvider":true,"documentSymbolProvider":true,"completionOptions":{"resolveProvider":false,"triggerCharacters":["."]}}}}))
    end
  end
end
