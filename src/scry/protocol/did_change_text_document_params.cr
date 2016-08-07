require "json"
require "./versioned_text_document_identifier"

module Scry

  struct DidChangeTextDocumentParams
    JSON.mapping({
      text_document: { type: VersionedTextDocumentIdentifier, key: "textDocument" },
      content_changes: { type: Array(TextDocumentContentChangeEvent), key: "contentChanges" }
    }, true)
  end

end