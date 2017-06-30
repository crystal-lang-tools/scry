require "json"

module Scry
  struct DidOpenTextDocumentParams
    JSON.mapping({
      text_document: {type: TextDocumentItem, key: "textDocument"},
    }, true)
  end

  struct TextDocumentItem
    JSON.mapping({
      uri:         String,
      language_id: {type: String, key: "languageId"},
      version:     Int32,
      text:        String,
    }, true)
  end
end
