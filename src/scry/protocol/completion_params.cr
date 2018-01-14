require "./text_document_identifier"
require "./position"
require "./completion_context"

module Scry
  struct CompletionParams
    JSON.mapping({
      text_document: {type: TextDocumentIdentifier, key: "textDocument"},
      position:      Position,
      context:       CompletionContext,
    }, true)
  end
end
