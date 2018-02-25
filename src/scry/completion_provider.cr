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
    METHOD_CALL_REGEX       = /(?<target>[a-zA-Z][a-zA-Z_:]*)\.(?<method>[a-zA-Z]*[a-zA-Z_:]*)$/
    INSTANCE_VARIABLE_REGEX = /(?<var>@[a-zA-Z_]*)$/
    REQUIRE_MODULE_REGEX    = /require\s*\"(?<import>[a-zA-Z\/._]*)$/

    def initialize(@text_document : TextDocument, @context : CompletionContext | Nil, @position : Position)
    end

    def run
      context = parse_context
      context.find
    end



    def parse_context
      line = @text_document.text.first.lines[@position.line][0..@position.character - 1]
      case line
      when METHOD_CALL_REGEX
        Completion::MethodCallContext.new($~["target"], $~["method"], line, @text_document)
      when INSTANCE_VARIABLE_REGEX
        Completion::InstanceVariableContext.new($~["var"], line, @text_document)
      when REQUIRE_MODULE_REGEX
        Completion::RequireModuleContext.new($~["import"], @text_document)
      else
        UnrecognizedContext.new
      end
    end
  end
end