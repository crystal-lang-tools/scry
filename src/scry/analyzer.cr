require "compiler/crystal/**"
require "./workspace"
require "./text_document"
require "./publish_diagnostic"

module Scry
  struct Analyzer
    @@source = [] of String

    def initialize(@workspace : Workspace, @text_document : TextDocument)
      @diagnostic = PublishDiagnostic.new(@workspace, @text_document.uri)
    end

    def run
      if @@source != @text_document.text
        @@source = @text_document.text
        @@source.map do |text|
          unless @text_document.filename.starts_with?("/usr/lib") ||
                 @text_document.filename.starts_with?("#{@workspace.root_uri}/lib")
            analyze(text)
          end
        end.flatten.uniq
      end
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
