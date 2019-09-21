module Scry::Protocol
  enum CompletionTriggerKind
    Invoked          = 1
    TriggerCharacter = 2
  end

  struct CompletionContext
    JSON.mapping({
      trigger_kind:      {type: CompletionTriggerKind, key: "triggerKind"},
      trigger_character: {type: String, key: "triggerCharacter"},
    }, true)

    def initialize(@trigger_kind, @trigger_character)
    end
  end
end
