require "./log"
require "compiler/crystal/crystal_path"
require "./completion/*"

module Scry
  class UnrecognizedContext < Completion::Context
    def find
      [] of CompletionItem
    end
  end

  class CompletionProvider
    METHOD_CALL_REGEX       = /(?<target>@?[a-zA-Z_][a-zA-Z_:]*)\.(?<method>[a-zA-Z]*[a-zA-Z_:]*)$/
    INSTANCE_VARIABLE_REGEX = /(?<var>@[a-zA-Z_]*)$/
    REQUIRE_MODULE_REGEX    = /require\s*\"(?<import>[a-zA-Z\/._]*)$/

    def initialize(@text_document : TextDocument, @context : CompletionContext | Nil, @position : Position, @method_db : Completion::MethodDB)
    end

    def run
      context = parse_context
      context.find
    end

    def parse_context
      lines = @text_document.source.lines[0..@position.line]
      lines[-1] = lines.last[0..@position.character - 1]
      lines = lines.join(" ")
      case lines
      when METHOD_CALL_REGEX
        Completion::MethodCallContext.new(lines, $~["target"], $~["method"], @method_db)
      when INSTANCE_VARIABLE_REGEX
        Completion::InstanceVariableContext.new($~["var"], lines, @text_document)
      when REQUIRE_MODULE_REGEX
        Completion::RequireModuleContext.new($~["import"], @text_document)
      else
        UnrecognizedContext.new
      end
    end
  end
end
