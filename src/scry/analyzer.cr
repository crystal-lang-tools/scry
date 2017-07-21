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
      @text_document.text.map do |text|
        unless inside_path?
          analyze(text)
        end
      end.flatten.uniq
    end

    private def inside_path?
      ENV["CRYSTAL_PATH"].split(':').each do |path|
        return true if @text_document.filename.starts_with?(path)
      end
      false
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
    ensure
      GC.collect
    end
  end
end
