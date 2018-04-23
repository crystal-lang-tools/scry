require "./workspace"
require "./text_document"
require "./publish_diagnostic"

module Scry
  struct Analyzer
    def initialize(@workspace : Workspace, @text_document : TextDocument)
      @diagnostic = PublishDiagnostic.new(@workspace, @text_document.uri)
    end

    def run
      unless @text_document.inside_crystal_path?
        @text_document.text.map do |text|
          analyze(text)
        end.flatten.uniq
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
        @diagnostic.full_clean
      else
        # Crystal compiler needs a main file to compile
        # By default it uses .scry.cr on workspace root,
        # if src dir exists and the error is caused by un undefined symbol,
        # then it requires ./src/* files
        # Otherwise You can create your own .scry.cr
        main_file = "#{root_uri}/.scry.cr"
        main_code = if File.exists?(main_file)
                      File.read(main_file)
                    elsif Dir.exists?("#{root_uri}/src") && response.includes?("undefined")
                      %(require "./src/*")
                    else
                      ""
                    end
        response = crystal_build(main_file, main_code)
        if response.empty?
          @diagnostic.full_clean
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
