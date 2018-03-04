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
      response = crystal_build(@text_document.filename, source)
      if response.empty?
        [@diagnostic.clean]
      else
        @diagnostic.from(response)
      end
    rescue ex
      Log.logger.error("A error was found while searching diagnostics\n#{ex}")
      nil
    end

    private def crystal_build(filename, source)
      code = IO::Memory.new(source)
      String.build do |io|
        Process.run("crystal", ["build", "--no-codegen", "--no-color", "--error-trace", "-f", "json", "--stdin-filename", filename], output: io, error: io, input: code)
      end
    end
  end
end
