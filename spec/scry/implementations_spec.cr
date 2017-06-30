require "../spec_helper"

module Scry
  describe Implementations do
    it "check implementation response type" do
      params = TextDocumentPositionParams.from_json(TEXTDOCUMENT_POSITION_PARAM_EXAMPLE)
      text_document = TextDocument.new(params, 0)
      impl = Implementations.new(text_document)
      impl.run.is_a?(ResponseMessage).should eq(true)
    end

    it "check implementation response content" do
      params = TextDocumentPositionParams.from_json(TEXTDOCUMENT_POSITION_PARAM_EXAMPLE)
      text_document = TextDocument.new(params, 0)
      impl = Implementations.new(text_document)
      response = impl.run
      response.to_json.should eq(IMPLEMENTATIONS_RESPONSE_EXAMPLE)
    end
  end
end
