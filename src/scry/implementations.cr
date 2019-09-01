require "./log"
require "./tool_helper"

module Scry
  # Using Crystal implementation to emulate GoTo Definition.
  struct Implementations
    include ToolHelper

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
        search(@text_document.filename, position)
      end
    end

    # NOTE: compiler is a bit heavy in some projects.
    def search(filename, position)
      local_require = get_local_require(filename, position)
      return local_require if local_require
      scope = get_scope(@workspace.root_uri)
      analyze(filename, position, scope)
    end

    LOCAL_REQUIRE_REGEX = /^require\s+"(\.{1,2}.*?)"\s*$/
    POSITION_0          = LSP::Protocol::Position.new(0, 0)
    RANGE_0             = LSP::Protocol::Range.new(POSITION_0, POSITION_0)

    private def get_local_require(filename, position)
      line = @text_document.get_line(position.line)
      if line && (match = line.match(LOCAL_REQUIRE_REGEX))
        if match.byte_begin(1) < position.character < match.byte_end(1)
          expanded = File.expand_path(match[1], File.dirname(filename))
          filepath = return_if_exists?(expanded) || return_if_exists?("#{expanded}.cr")
          if filepath
            uri = "file://#{filepath}"
            location = LSP::Protocol::Location.new(uri, RANGE_0)
            return [LSP::Protocol::ResponseMessage.new(@text_document.id, location)]
          end
        end
      end
    end

    private def crystal_tool(filename, position, scope)
      location = "#{filename}:#{position.line + 1}:#{position.character + 1}"
      String.build do |io|
        args = ["tool", "implementations", "--no-color", "--error-trace", "-f", "json", "-c", location] + scope
        Process.run("crystal", args, output: io, error: io)
      end
    end

    private def analyze(filename, position, scope)
      result = crystal_tool(filename, position, scope)
      Log.logger.debug("result: #{result}")
      response = (Array(LSP::BuildFailure) | ImplementationsResponse).from_json(result)
      case response
      when Array(LSP::BuildFailure)
        implementation_response
      when ImplementationsResponse
        if impls = response.implementations
          response_with(impls)
        else
          implementation_response
        end
      end
    rescue ex
      Log.logger.error("A error was found while searching implementations\n#{ex}\n#{result}")
      implementation_response
    end

    def implementation_response(locations = [] of LSP::Protocol::Location)
      LSP::Protocol::ResponseMessage.new(@text_document.id, locations)
    end

    private def response_with(implementations)
      locations = implementations.map do |item|
        pos = LSP::Protocol::Position.new(item.line - 1, item.column - 1)
        range = LSP::Protocol::Range.new(pos, pos)
        LSP::Protocol::Location.new("file://" + item.filename, range)
      end
      implementation_response(locations)
    end

    private def return_if_exists?(path)
      File.exists?(path) && path
    end
  end
end
