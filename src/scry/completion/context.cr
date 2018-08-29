module Scry::Completion
  abstract class Context
    abstract def find : Array(Protocol::CompletionItem)
  end
end
