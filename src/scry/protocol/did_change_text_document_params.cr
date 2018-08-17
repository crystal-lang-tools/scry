module Scry::Protocol
  struct DidChangeTextDocumentParams
    JSON.mapping({
      text_document:   {type: VersionedTextDocumentIdentifier, key: "textDocument"},
      content_changes: {type: Array(TextDocumentContentChangeEvent), key: "contentChanges"},
    }, true)
  end
end
