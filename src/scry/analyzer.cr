require "./workspace"
require "./log"
require "compiler/crystal/**"

module Scry

  class Analyzer

    private getter workspace : Workspace
    private getter uri : String
    private getter text : String
    private getter filename : String

    def initialize(@workspace, params : DidOpenTextDocumentParams)
      @uri = params.text_document.uri
      @filename = @uri.sub("file://", "")
      @text = params.text_document.text
    end

    def initialize(@workspace, params : DidOpOnTextDocumentParams)
      @uri = params.text_document.uri
      @filename = @uri.sub("file://", "")
      @text = read_file
    end

    def initialize(@workspace, file_event : FileEvent)
      @uri = file_event.uri
      @filename = @uri.sub("file://", "")
      @text = read_file
    end

    def run
      source = Crystal::Compiler::Source.new(filename, text)
      compiler = Crystal::Compiler.new
      compiler.color = false
      compiler.no_codegen = true
      compiler.compile source, source.filename + ".out"

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

    private def read_file : String
      File.read(filename)
    rescue ex : IO::Error
      Log.logger.warn ex.message
      ""
    end

  end

end
