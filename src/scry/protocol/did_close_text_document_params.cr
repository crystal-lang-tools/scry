require "json"

module Scry

  struct DidCloseTextDocumentParams
    JSON.mapping({
      text_document: { type: TextDocumentIdentifier, key: "textDocument" }
    })
  end

end