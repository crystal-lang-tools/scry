require "../spec_helper"
require "../../src/scry/parse_analyzer"
require "../../src/scry/text_document"

module Scry

  describe ParseAnalyzer do

    it "only analyzes syntax" do
      good_syntax = %(require "foo"\n\nputs something)
      workspace = Workspace.new("/foo", 1.to_i64, 100)
      text_document = TextDocument.new("inmemory://model/3", [good_syntax])
      analyzer = ParseAnalyzer.new(workspace, text_document)
      results = analyzer.run
      results.should eq(
        [PublishDiagnosticsNotification.empty("inmemory://model/3")]
      )
    end

    it "catches syntax errors" do
      broken_syntax = %(require "foo"\n\ndef thing\n)
      workspace = Workspace.new("/foo", 1.to_i64, 100)
      text_document = TextDocument.new("inmemory://model/3", [broken_syntax])
      analyzer = ParseAnalyzer.new(workspace, text_document)
      results = analyzer.run
      publishable_diagnostic = results.first
      publishable_diagnostic.empty?.should be_false
    end

  end

end
