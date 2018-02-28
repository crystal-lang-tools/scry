module Scry::Completion
  abstract class Context
    abstract def find : Array(CompletionItem)
  end
end
