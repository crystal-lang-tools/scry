require "../../spec_helper"

module Scry

  describe Initialize do

    it "build a new workspace" do
      initer = Initialize.new(
        InitializeParams.from_json({
          processId: 1,
          rootPath: "/Users/foo/some_project",
          capabilities: {} of String => String
        }.to_json)
      )
      workspace, response = initer.run
      workspace.should_not be_nil
      response.to_json.should eq(%({"capabilities":{"textDocumentSync":1}}))
    end

  end
end