module LSP::Protocol
  struct CompletionParams
    JSON.mapping({
      text_document: {type: TextDocumentIdentifier, key: "textDocument"},
      position:      Position,
      context:       CompletionContext,
    }, true)
  end
end
