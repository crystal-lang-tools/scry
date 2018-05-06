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

    # NOTE: this Would be configurable in the future with scry.yml
    private def response_with(contexts, range)
      content = vertical_align(contexts)
      # content = horizontal_align(contexts)
      hover_response(Hover.new(MarkupContent.new("markdown", content), range))
    end

    # Aligns context output vertically. By example:
    #
    # **Context 1**
    #
    # ```crystal
    # arg1 : String
    # arg2 : Int32 ∣ Nil
    # ```
    #
    # **Context 2**
    #
    # ```crystal
    # arg1 : String
    # arg2 : Bool
    # ```
    private def vertical_align(contexts)
      contents = IO::Memory.new
      max_size = 0
      contexts.each do |context|
        size = context.keys.max_by(&.size).size
        max_size = size if size > max_size
      end
      contexts.each_with_index do |context, i|
        contents << "**Context #{i + 1}**\n" if contexts.size > 1
        contents << "```crystal\n"
        context.each do |var_name, var_type|
          var_name_aligned = var_name.ljust(max_size)
          contents << "#{var_name_aligned} : #{var_type}\n"
        end
        contents << "```\n"
      end
      contents.to_s
    end

    # Aligns context output horizontally. By example:
    #
    # | Expression | Type 1 | Type 2 |
    # | :--- | :--- | :--- |
    # | arg1 | `String` | `String` |
    # | arg2 | `Int32 ∣ Nil` | `Bool` |
    private def horizontal_align(contexts)
      contents = IO::Memory.new
      contents << "| Expression |"
      contexts.each_with_index do |context, i|
        if contexts.size > 1
          contents << " Type #{i + 1} |"
        else
          contents << " Type |"
        end
      end
      contents << "\n"
      contents << "| :--- |"
      contexts.each_with_index do |context, i|
        contents << " :--- |"
      end
      contents << "\n"
      contents_hash = {} of String => Array(String)
      contexts.each_with_index do |context, i|
        context.each do |var_name, var_type|
          # Replaces | by unicode symbol 0x2223 (DIVIDES)
          escaped_var_type = "`#{var_type.gsub("|", "∣")}`"
          if contents_hash[var_name]?
            contents_hash[var_name] << escaped_var_type
          else
            contents_hash[var_name] = [escaped_var_type]
          end
        end
      end
      contents_hash.each do |var_name, var_type|
        contents << "| #{var_name} | #{var_type.join(" | ")} |\n"
      end
      contents.to_s
    end
  end
end
