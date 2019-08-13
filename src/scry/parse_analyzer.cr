require "compiler/crystal/syntax"
require "compiler/crystal/codegen/target"
require "compiler/crystal/crystal_path"
require "./workspace"
require "./text_document"
require "./publish_diagnostic"
require "./missing_methods"

module Scry
  struct ParseAnalyzer
    def initialize(@workspace : Workspace, @text_document : TextDocument)
      @diagnostic = PublishDiagnostic.new(@workspace, @text_document.uri)
    end

    def run
      @text_document.text.map { |t| parse_source(t) }.flatten.uniq
    end

    private def parse_source(source : String)
      parser = Crystal::Parser.new(source)
      parser.filename = @text_document.filename
      parser.parse
      [@diagnostic.clean]
    rescue ex : Crystal::Exception
      @diagnostic.from(ex.to_json)
    end
  end
end
