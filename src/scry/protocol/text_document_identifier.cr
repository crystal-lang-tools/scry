require "json"

module Scry

  struct TextDocumentIdentifier
    JSON.mapping({
      uri: String
    }, true)
  end

end