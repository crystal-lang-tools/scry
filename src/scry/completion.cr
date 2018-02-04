require "./log"

module Scry
  # struct CompletionContext
  #   type
  # end
  alias AutoCompletionContext = InstanceMethodCallContext
  class UnrecognizedContext < Exception
  end

  struct InstanceMethodCallContext
    def initialize(@target : String, @method : String)
    end

    def to_completion_items(results : Array(String))
      results.map do |res|
        CompletionItem.new(res, CompletionItemKind::Method, res)
      end
    end
  end

  class Completion
    METHOD_CALL_REGEX = /(?<target>[a-zA-Z][a-zA-Z_:]*)\.(?<method>[a-zA-Z]*[a-zA-Z_:]*)$/
    def initialize(@text_document : TextDocument, @context : CompletionContext | Nil, @position : Position)
    end

    def run
      context = parse_context
      find_with_context(context)
    end

    def find_with_context(context : InstanceMethodCallContext)
      context.to_completion_items(["Results", "And", "more", "results"])
    end

    def parse_context
      line = @text_document.text.first.lines[@position.line][0..@position.character]

      if(match = line.match(METHOD_CALL_REGEX))
        InstanceMethodCallContext.new(match["target"], match["method"])
      else
        raise UnrecognizedContext.new("Couldn't identify context of: #{line}")
      end
    end
  end
end
