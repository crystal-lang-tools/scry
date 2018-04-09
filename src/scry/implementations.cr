require "./log"
require "./protocol/location"

module Scry
  # Using Crystal implementation to emulate GoTo Definition.
  struct Implementations
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
      if Dir.exists?("#{root_uri}/src")
        Dir.glob("#{root_uri}/src/*.cr")
      else
        Dir.glob("#{root_uri}/**/*.cr").reject(&.=~(/\/spec\/|\/lib\//))
      end
    end

    # NOTE: compiler is a bit heavy in some projects.
    def search(filename, source, position)
      scope = get_scope
      result = analyze(filename, position, scope)
      case result
      when ResponseMessage
        result
      when JSON::Any
        response_with(result)
      end
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
      parsed_response = JSON.parse(response)
      implementations = parsed_response["implementations"]?
      if implementations
        implementations
      else
        implementation_response
      end
    rescue ex
      Log.logger.error("A error was found while searching definitions\n#{ex}")
      implementation_response
    end

    def implementation_response(locations = [] of Location)
      ResponseMessage.new(@text_document.id, locations)
    end

    private def response_with(implementations)
      locations = implementations.map do |item|
        pos = Position.new(item["line"].as_i - 1, item["column"].as_i - 1)
        range = Range.new(pos, pos)
        Location.new("file://" + item["filename"].as_s, range)
      end
      implementation_response(locations)
    end
  end
end
