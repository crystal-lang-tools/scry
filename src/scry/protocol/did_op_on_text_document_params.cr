require "json"
require "./text_document_identifier"

module Scry

  struct DidOpOnTextDocumentParams
    JSON.mapping({
      text_document: { type: TextDocumentIdentifier, key: "textDocument" }
    }, true)
  end

end