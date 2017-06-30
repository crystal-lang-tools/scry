require "../spec_helper"

module Scry
  describe Initializer do
    it "build a new workspace" do
      initer = Initializer.new(
        InitializeParams.from_json({
          processId:    1,
          rootPath:     "/homa/main/Projects/Experiment",
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
