require "../spec_helper"

module Scry
  describe Formatter do
    it "check formatter response type" do
      workspace = Workspace.new("root_uri", 0, 10)
      text_document = TextDocument.new("uri", ["1+1"])
      format = Formatter.new(workspace, text_document)
      format.run.is_a?(ResponseMessage).should eq(true)
    end

    it "check formatter response content" do
      workspace = Workspace.new("root_uri", 0, 10)
      text_document = TextDocument.new("uri", ["1+1"])
      format = Formatter.new(workspace, text_document)
      response = format.run
      response.to_json.should eq(FORMATTER_RESPONSE_EXAMPLE)
    end
  end
end
