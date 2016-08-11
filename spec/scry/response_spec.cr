require "../spec_helper"
require "../../src/scry/response"

module Scry

  describe Response do

    it "doesn't write if result is Nil" do
      results = [] of PublishDiagnosticsNotification | ServerCapabilities | Nil
      results << nil

      io = MemoryIO.new
      response = Response.new(results)
      response.write(io)
      io.to_s.should eq("")
    end

    it "responds with published diagnostics" do
      diagnostic = Diagnostic.new("some_file.cr", 3, 1, 14, "oops, a syntax error")

      results = [] of PublishDiagnosticsNotification | ServerCapabilities | Nil
      results << PublishDiagnosticsNotification.new(
        "file:///Users/foo/project/some_file.cr",
        [diagnostic]
      )

      io = MemoryIO.new
      response = Response.new(results)
      response.write(io)
      io.to_s[0...19].should eq("Content-Length: 283")
    end

    it "responds with server capabilities" do
      server_cap = ServerCapabilities.new(32)

      results = [] of PublishDiagnosticsNotification | ServerCapabilities | Nil
      results << server_cap

      io = MemoryIO.new
      response = Response.new(results)
      response.write(io)
      io.to_s.should eq(%(Content-Length: 74\r\n\r\n{"jsonrpc":"2.0","id":32,"result":{"capabilities":{"textDocumentSync":1}}}))
    end

  end

end
