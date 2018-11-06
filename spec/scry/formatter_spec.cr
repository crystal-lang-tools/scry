require "../spec_helper"

module Scry
  describe Formatter do
    it "check formatter response type" do
      workspace = Workspace.new("root_uri", 0, 10)
      text_document = TextDocument.new("uri", ["1+1"])
      format = Formatter.new(workspace, text_document)
      format.run.is_a?(Protocol::ResponseMessage).should eq(true)
    end

    it "check formatter response content" do
      workspace = Workspace.new("root_uri", 0, 10)
      text_document = TextDocument.new("uri", ["1+1"])
      format = Formatter.new(workspace, text_document)
      response = format.run
      response.to_json.should eq(FORMATTER_RESPONSE_EXAMPLE)
    end

    it "check formatter on untitled file" do
      workspace = Workspace.new("root_uri", 0, 10)
      workspace.put_file(TextDocument.new(Protocol::DidOpenTextDocumentParams.from_json(UNTITLED_FORMATTER_EXAMPLE)))
      text_document, empty_completion = workspace.open_files["untitled:Untitled-1"]
      format = Formatter.new(workspace, text_document)
      response = format.run
      response.to_json.should eq(FORMATTER_RESPONSE_EXAMPLE)
    end
  end
end
