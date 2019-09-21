module Scry::Completion
  class InstanceVariableContext < Context
    def initialize(@var : String, @line : String, @text_document : TextDocument)
    end

    def find
      # to_completion_items(["Results", "And", "more", "results"])
      # TODO implement instance variable completion
      [] of LSP::Protocol::CompletionItem
    end

    def to_completion_items(results : Array(String))
      results.map do |res|
        LSP::Protocol::CompletionItem.new(res, LSP::Protocol::CompletionItemKind::Variable, res)
      end
    end
  end
end
