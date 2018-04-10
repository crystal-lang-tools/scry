require "json"
require "./text_document_identifier"
require "./versioned_text_document_identifier"

module Scry
  struct TextDocumentParams
    JSON.mapping({
      text_document: {type: (TextDocumentIdentifier | VersionedTextDocumentIdentifier), key: "textDocument"},
      text:          String?,
      include_text:  {type: Bool, nilable: true, key: "includeText"},
    }, true)
  end
end
