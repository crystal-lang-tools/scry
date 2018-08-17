require "json"

module Scry::Protocol
  struct TextDocumentIdentifier
    JSON.mapping({
      uri: String,
    }, true)
  end
end
