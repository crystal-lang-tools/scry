require "./workspace"
require "./text_document"
require "./publish_diagnostic"

module Scry
  struct Analyzer
    def initialize(@workspace : Workspace, @text_document : TextDocument)
      @diagnostic = PublishDiagnostic.new(@workspace, @text_document.uri)
    end

    def run
      if @text_document.inside_crystal_path?
        clean_diagnostic
      else
        @text_document.text.map do |text|
          analyze(text)
        end
      end.flatten.uniq
    end

    # Reset all diagnostics in the current project
    def clean_diagnostic
      Dir.glob("#{@workspace.root_uri}/**/*.cr").map do |file|
        @diagnostic.clean("file://#{file}")
      end
    end

    # Analyze the code twice,
    # first time analyzes a single file and stop if no error
    # second time analyzes the entire project requiring the first level files inside src folder
    private def analyze(source)
      filename = @text_document.filename
      root_uri = @workspace.root_uri
      response = crystal_build(filename, source)
      if response.empty?
        clean_diagnostic
      else
        if Dir.exists?("#{root_uri}/src") && response.includes?("undefined")
          response = crystal_build("#{root_uri}/.scry.cr", %(require "./src/*"))
          if response.empty?
            clean_diagnostic
          else
            @diagnostic.from(response)
          end
        else
          @diagnostic.from(response)
        end
      end
    rescue ex
      Log.logger.error("A error was found while searching diagnostics\n#{ex}")
      nil
    end

    private def crystal_build(filename, source)
      code = IO::Memory.new(source)
      String.build do |io|
        Process.run("crystal", ["build", "--no-debug", "--no-codegen", "--no-color", "--error-trace", "-f", "json", "--stdin-filename", filename], output: io, error: io, input: code)
      end
    end
  end
end
