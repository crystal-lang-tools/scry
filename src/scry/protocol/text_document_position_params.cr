require "./text_document_identifier"
require "./position"

module Scry
  struct TextDocumentPositionParams
    JSON.mapping({
      text_document: {type: TextDocumentIdentifier, key: "textDocument"},
      position:      Position,
    }, true)
  end
end
