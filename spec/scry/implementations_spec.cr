require "../spec_helper"

module Scry
  describe Implementations do
    it "check implementation response type" do
      params = TextDocumentPositionParams.from_json(TEXTDOCUMENT_POSITION_PARAM_EXAMPLE)
      text_document = TextDocument.new(params, 0)
      workspace = Workspace.new("root_uri", 0, 10)
      impl = Implementations.new(workspace, text_document)
      impl.run.is_a?(ResponseMessage).should eq(true)
    end
  end
end
