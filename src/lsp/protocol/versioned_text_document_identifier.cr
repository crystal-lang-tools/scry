module LSP::Protocol
  struct VersionedTextDocumentIdentifier
    JSON.mapping({
      uri:     String,
      version: Int32,
    }, true)
  end
end
