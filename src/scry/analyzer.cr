require "./workspace"
require "./log"

require "./text_document"
require "compiler/crystal/**"

module Scry

  class Analyzer

    private getter workspace : Workspace
    private getter text_document : TextDocument

    def initialize(@workspace, @text_document)
    end

    def run
      text.map { |t| analyze(t) }.flatten.uniq
    end

    private def analyze(some_text)
      source = Crystal::Compiler::Source.new(filename, some_text)
      compiler = Crystal::Compiler.new
      compiler.color = false
      compiler.no_codegen = true
      compiler.debug = Crystal::Debug::None
      # compiler.compile source, source.filename + ".out"
      # Is like ParseAnalyzer
      # Compiler is a bit unresponsible in some projects
      compiler.top_level_semantic(source)

      [clean_diagnostic]
    rescue ex : Crystal::Exception
      to_diagnostics(ex)
    end

    private def to_diagnostics(ex)
      build_failures = Array(BuildFailure).from_json(ex.to_json)
      build_failures
        .uniq
        .first(workspace.max_number_of_problems)
        .map { |bf| Diagnostic.new(bf) }
        .group_by { |diag| diag.uri }
        .map { |file, diagnostics|
          PublishDiagnosticsNotification.new(file, diagnostics)
        }
    end

    private def clean_diagnostic
      PublishDiagnosticsNotification.empty(uri)
    end

    private def filename
      text_document.filename
    end

    private def text
      text_document.text
    end

    private def uri
      text_document.uri
    end

  end

end
