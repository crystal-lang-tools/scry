require "./workspace"
require "compiler/crystal/**"

module Scry

  class ParseAnalyzer

    def initialize(@workspace, @params : DidChangeTextDocumentParams)
    end

    def call
      params.content_changes.map { |change|
        parse_source change.text
      }
    end

    private def parse_source(source : String)
      parser = Crystal::Parser.new(source)
      parser.filename = filename
      parser.parse

      [clean_diagnostic]
    rescue ex : Crystal::Exception
      to_diagnostics(ex)
    end

    private def filename
      params.text_document.uri.sub("file://", "")
    end

  end

end
