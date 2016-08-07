require "json"

module Scry

  struct DidSaveTextDocumentParams
    JSON.mapping({
      text_document: { type: TextDocumentIdentifier, key: "textDocument" }
    }, true)
  end

end