require "../workspace"
require "../protocol/text_document"
require "compiler/crystal/**"

module Scry

  class Analyzer

    private getter! workspace : Workspace
    private getter! document : TextDocument

    def initialize(@workspace, params : TextDocument)
      @document = params
    end

    def initialize(@workspace, anything)
      raise "Can't analyze #{anything.inspect}"
    end

    def run
      source = Crystal::Compiler::Source.new(
        document.text_document.uri.sub("file://", ""),
        document.text_document.text
      )
      compiler = Crystal::Compiler.new
      compiler.color = false
      compiler.no_codegen = true
      compiler.compile source, source.filename + ".out"

      { workspace, nil }
    rescue ex : Crystal::Exception
      { workspace, to_diagnostics(ex) }
    end

    private def to_diagnostics(ex)
      build_failures = Array(BuildFailure).from_json(ex.to_json)
      build_failures
        .map { |bf| Diagnostic.new(bf) }
        .group_by { |diag| diag.uri }
        .map { |file, diagnostics|
          PublishDiagnosticsNotification.new(file, diagnostics)
        }
    end

    private def to_json(ex)
      String.build { |io| ex.to_json(io) }
    end


  end

end