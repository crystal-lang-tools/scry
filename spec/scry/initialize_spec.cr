require "../spec_helper"

module Scry
  describe Initializer do
    it "build a new workspace" do
      initer = Initializer.new(
        LSP::Protocol::InitializeParams.from_json({
          processId:    1,
          rootPath:     "/home/main/Projects/Experiment",
          capabilities: {} of String => String,
          trace:        "off",
        }.to_json),
        32
      )
      workspace, response = initer.run
      workspace.should_not be_nil
    end
  end
end
