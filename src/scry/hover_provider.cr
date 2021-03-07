require "./log"
require "./tool_helper"
require "./build_failure"

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
      result = crystal_tool(filename, position, scope)
      response = (Array(BuildFailure) | HoverResponse).from_json(result)
      case response
      when Array(BuildFailure)
        hover_response
      when HoverResponse
        if contexts = response.contexts
          response_with(contexts, LSP::Protocol::Range.new(position, position))
        else
          hover_response
        end
      end
    rescue ex
      Log.error { "A error was found while searching contexts\n#{ex}\n#{result}" }
      hover_response
    end

    def hover_response(context = LSP::Protocol::Hover.new(LSP::Protocol::MarkupContent.new("", "")))
      LSP::Protocol::ResponseMessage.new(@text_document.id, context)
    end

    # NOTE: this Would be configurable in the future with scry.yml
    private def response_with(contexts, range)
      content = vertical_align(contexts)
      # content = horizontal_align(contexts)
      hover_response(LSP::Protocol::Hover.new(LSP::Protocol::MarkupContent.new("markdown", content), range))
    end

    # Aligns context output vertically. By example:
    #
    # **Context 1**
    #
    # ```
    # arg1 : String
    # arg2 : Int32 ∣ Nil
    # ```
    #
    # **Context 2**
    #
    # ```
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
    def horizontal_align(contexts)
      contents = IO::Memory.new

      # Header
      if contexts.size == 1
        contents << "| Expression | Type |"
      else
        contents << "| Expression |"
        contexts.size.times do |i|
          contents << " Type #{i + 1} |"
        end
      end
      contents.puts

      # Lines
      contents << "| :--- |"
      contexts.size.times { contents << " :--- |" }
      contents.puts

      # Types
      # > group var types (for all context) for each var
      types_per_var = {} of String => Array(String)
      contexts.each do |ctx|
        ctx.each do |var_name, var_type|
          # Replaces | by unicode symbol 0x2223 (DIVIDES)
          # as | can conflicts with the markdown table
          escaped_var_type = "`#{var_type.gsub("|", "∣")}`"
          if types = types_per_var[var_name]?
            types << escaped_var_type
          else
            types_per_var[var_name] = [escaped_var_type]
          end
        end
      end
      # > print types, var by var
      types_per_var.each do |var_name, var_type|
        contents.puts "| #{var_name} | #{var_type.join(" | ")} |"
      end

      contents.to_s
    end
  end
end
