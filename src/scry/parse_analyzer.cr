require "./workspace"
require "compiler/crystal/**"

module Scry

  class ParseAnalyzer

    def initialize(@workspace : Workspace, @text_document : TextDocument)
    end

    def run
      @text_document.text.map { |t| parse_source t }.flatten.uniq
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
      @text_document.filename
    end

    private def uri
      @text_document.uri
    end

    private def clean_diagnostic
      PublishDiagnosticsNotification.empty(uri)
    end

    private def to_diagnostics(ex)
      build_failures = Array(BuildFailure).from_json(ex.to_json)
      build_failures
        .uniq
        .first(@workspace.max_number_of_problems)
        .map { |bf| Diagnostic.new(bf) }
        .group_by { |diag| diag.uri }
        .map { |file, diagnostics|
          PublishDiagnosticsNotification.new(file, diagnostics)
        }
    end

  end

end
