require "./log"
require "./protocol/location"

module Scry
  # Using Crystal implementation to emulate GoTo Definition.
  struct Implementations
    def initialize(@text_document : TextDocument)
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

    # NOTE: compiler is a bit heavy in some projects.
    def search(filename, source, position)
      response = crystal_tool(filename, position)
      parsed_response = JSON.parse(response)
      impls = parsed_response["implementations"]?
      if impls
        locations = impls.map do |impl|
          pos = Position.new(impl["line"].as_i, impl["column"].as_i)
          range = Range.new(pos, pos)
          Location.new("file://" + impl["filename"].as_s, range)
        end
        ResponseMessage.new(@text_document.id, locations)
      else
        ResponseMessage.new(@text_document.id, [] of Location)
      end
    rescue ex
      Log.logger.error("A error was found while searching definitions\n#{ex}")
      nil
    end

    private def crystal_tool(filename, position)
      location = "#{filename}:#{position.line + 1}:#{position.character + 1}"
      String.build do |io|
        Process.run("crystal", ["tool", "implementations", "--no-color", "--error-trace", "-f", "json", "-c", "#{location}", filename], output: io, error: io)
      end
    end
  end
end
