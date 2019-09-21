module LSP::Protocol
  struct DocumentFormattingParams
    JSON.mapping({
      text_document: {type: TextDocumentIdentifier, key: "textDocument"},
      options:       FormattingOptions,
    }, true)
  end
end
