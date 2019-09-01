module Scry::Completion
  abstract class Context
    abstract def find : Array(LSP::Protocol::CompletionItem)
  end
end
