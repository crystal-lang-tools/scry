require "../spec_helper"

module Scry
  describe ParseAnalyzer do
    it "only analyzes syntax" do
      good_syntax = %(require "foo"\n\nputs something)
      workspace = Workspace.new("/foo", 1.to_i64, 100)
      text_document = TextDocument.new("inmemory://model/3", [good_syntax])
      analyzer = ParseAnalyzer.new(workspace, text_document)
      results = analyzer.run
      results.should eq(
        [PublishDiagnostic.new(workspace, "inmemory://model/3").clean]
      )
    end

    it "catches syntax errors" do
      broken_syntax = %(require "foo"\n\ndef thing\n)
      workspace = Workspace.new("/foo", 1.to_i64, 100)
      text_document = TextDocument.new("inmemory://model/3", [broken_syntax])
      analyzer = ParseAnalyzer.new(workspace, text_document)
      results = analyzer.run
      publishable_diagnostic = results.first
      params = publishable_diagnostic.params.as(PublishDiagnosticsParams)
      params.diagnostics.empty?.should be_false
    end
  end
end
