require "./log"
require "./build_failure"
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
    POSITION_0 = Protocol::Position.new(0, 0)
    RANGE_0 = Protocol::Range.new(POSITION_0, POSITION_0)

    private def get_local_require(filename, position)
      line = @text_document.get_line(position.line)
      if match = line.match(LOCAL_REQUIRE_REGEX)
        requirement = match[1]
        start_pos = line.index(requirement)
        return unless start_pos
        end_pos = start_pos + requirement.size - 1
        if position.character > start_pos || position.character < end_pos
          filepath = "#{File.expand_path(requirement, File.dirname(filename))}.cr"
          if File.exists?(filepath)
            uri = "file://#{filepath}"
            location = Protocol::Location.new(uri, RANGE_0)
            return [Protocol::ResponseMessage.new(@text_document.id, location)]
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
      response = (Array(BuildFailure) | ImplementationsResponse).from_json(result)
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
      Log.logger.error("A error was found while searching implementations\n#{ex}\n#{result}")
      implementation_response
    end

    def implementation_response(locations = [] of Protocol::Location)
      Protocol::ResponseMessage.new(@text_document.id, locations)
    end

    private def response_with(implementations)
      locations = implementations.map do |item|
        pos = Protocol::Position.new(item.line - 1, item.column - 1)
        range = Protocol::Range.new(pos, pos)
        Protocol::Location.new("file://" + item.filename, range)
      end
      implementation_response(locations)
    end
  end
end
