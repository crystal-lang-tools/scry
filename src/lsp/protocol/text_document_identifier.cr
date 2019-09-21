module LSP::Protocol
  struct TextDocumentIdentifier
    JSON.mapping({
      uri: String,
    }, true)
  end
end
