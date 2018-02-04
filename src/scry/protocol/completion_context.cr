module Scry
  enum CompletionTriggerKind
    Invoked          = 1
    TriggerCharacter = 2
  end

  struct CompletionContext
    JSON.mapping({
      triggerKind:      CompletionTriggerKind,
      triggerCharacter: String,
    }, true)

    def initialize(@triggerKind, @triggerCharacter)
    end
  end
end
