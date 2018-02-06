module Scry::Completion
    class MethodCallContext < Context
        def initialize(@target : String, @method : String, @line : String, @text_document : TextDocument)
        end

        def find
        # to_completion_items(["Results", "And", "more", "results"])
        # TODO implement method call comlpetion


        [] of CompletionItem
        end

        def to_completion_items(results : Array(String))
        results.map do |res|
            CompletionItem.new(res, CompletionItemKind::Method, res)
        end
        end
    end
end