module Scry::Protocol
  struct TextDocumentPositionParams
    JSON.mapping({
      text_document: {type: TextDocumentIdentifier, key: "textDocument"},
      position:      Position,
      context:       {nilable: true, type: CompletionContext},
    }, true)
  end
end
