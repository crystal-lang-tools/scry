require "json"

module Scry

  struct TextDocumentContentChangeEvent
    JSON.mapping({
      text: String
    }, true)
  end
end