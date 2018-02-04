require "./text_document_identifier"
require "./position"
require "./completion_context"
module Scry
  struct TextDocumentPositionParams
    JSON.mapping({
      text_document: {type: TextDocumentIdentifier, key: "textDocument"},
      position:      Position,
      context:       {nilable: true, type: CompletionContext}
    }, true)
  end
end
