require "compiler/crystal/**"
require "./workspace"
require "./text_document"
require "./publish_diagnostic"

module Scry
  struct Analyzer
    def initialize(@workspace : Workspace, @text_document : TextDocument)
      @diagnostic = PublishDiagnostic.new(@workspace, @text_document.uri)
    end

    def run
      @text_document.text.map { |t| analyze(t) }.flatten.uniq
    end

    # NOTE: compiler is a bit heavy in some projects.
    private def analyze(source)
      source = Crystal::Compiler::Source.new(@text_document.filename, source)
      compiler = Crystal::Compiler.new
      compiler.color = false
      compiler.no_codegen = true
      compiler.debug = Crystal::Debug::None
      compiler.compile(source, source.filename + ".out")
      [@diagnostic.clean]
    rescue ex : Crystal::Exception
      @diagnostic.from(ex)
    end
  end
end
