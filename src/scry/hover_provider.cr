require "./log"
require "./protocol/location"
require "./protocol/hover"
require "./build_failure"
require "./tool_helper"

module Scry
  struct HoverProvider
    include ToolHelper

    struct HoverResponse
      JSON.mapping(
        status: String,
        message: String,
        contexts: Array(Hash(String, String))?
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
      scope = get_scope(@workspace.root_uri)
      analyze(filename, position, scope)
    end

    private def crystal_tool(filename, position, scope)
      location = "#{filename}:#{position.line + 1}:#{position.character + 1}"
      String.build do |io|
        args = ["tool", "context", "--no-color", "--error-trace", "-f", "json", "-c", location, filename] + scope
        Process.run("crystal", args, output: io, error: io)
      end
    end

    private def analyze(filename, position, scope)
      response = crystal_tool(filename, position, scope)
      Log.logger.debug("response: #{response}")
      response = (Array(BuildFailure) | HoverResponse).from_json(response)
      case response
      when Array(BuildFailure)
        hover_response
      when HoverResponse
        if contexts = response.contexts
          response_with(contexts, Range.new(position, position))
        else
          hover_response
        end
      end
    rescue ex
      Log.logger.error("A error was found while searching contexts\n#{ex}")
      hover_response
    end

    def hover_response(context = Hover.new(MarkupContent.new("", "")))
      ResponseMessage.new(@text_document.id, context)
    end

    private def response_with(contexts, range)
      contents = ["```crystal"]
      contexts.each do |context|
        context.each do |key, value|
          contents << "#{key} : #{value}\n"
        end
      end
      contents << "```"
      hover_response(Hover.new(MarkupContent.new("markdown", contents.join('\n')), range))
    end
  end
end
