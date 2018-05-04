require "./log"
require "./protocol/location"
require "./build_failure"

module Scry
  # Using Crystal implementation to emulate GoTo Definition.
  struct Implementations
    struct ImplementationsResponse
      JSON.mapping(
        status: String,
        message: String,
        implementations: Array(ImplementationLocation)?
      )
    end

    struct ImplementationLocation
      JSON.mapping(
        line: Int32,
        column: Int32,
        filename: String
      )
    end

    def initialize(@workspace : Workspace, @text_document : TextDocument)
    end

    def run
      if position = @text_document.position
        search(
          @text_document.filename,
          @text_document.text.first,
          position
        )
      end
    end

    def get_scope
      root_uri = @workspace.root_uri
      main_file = "#{root_uri}/.scry.cr"
      if File.exists?(main_file)
        [main_file]
      elsif Dir.exists?("#{root_uri}/src")
        Dir.glob("#{root_uri}/src/*.cr")
      else
        Dir.glob("#{root_uri}/**/*.cr")
      end
    end

    # NOTE: compiler is a bit heavy in some projects.
    def search(filename, source, position)
      scope = get_scope
      analyze(filename, position, scope)
    end

    private def crystal_tool(filename, position, scope)
      location = "#{filename}:#{position.line + 1}:#{position.character + 1}"
      String.build do |io|
        args = ["tool", "implementations", "--no-color", "--error-trace", "-f", "json", "-c", "#{location}"] + scope
        Process.run("crystal", args, output: io, error: io)
      end
    end

    private def analyze(filename, position, scope)
      response = crystal_tool(filename, position, scope)
      Log.logger.debug("response: #{response}")
      response = (Array(BuildFailure) | ImplementationsResponse).from_json(response)
      case response
      when Array(BuildFailure)
        implementation_response
      when ImplementationsResponse
        if impls = response.implementations
          response_with(impls)
        else
          implementation_response
        end
      end
    rescue ex
      Log.logger.error("A error was found while searching implementations\n#{ex}")
      implementation_response
    end

    def implementation_response(locations = [] of Location)
      ResponseMessage.new(@text_document.id, locations)
    end

    private def response_with(implementations)
      locations = implementations.map do |item|
        pos = Position.new(item.line - 1, item.column - 1)
        range = Range.new(pos, pos)
        Location.new("file://" + item.filename, range)
      end
      implementation_response(locations)
    end
  end
end
