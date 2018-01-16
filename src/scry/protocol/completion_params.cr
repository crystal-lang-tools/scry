require "./text_document_params"
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
