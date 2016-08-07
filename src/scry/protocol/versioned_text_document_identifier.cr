require "json"

module Scry

  struct VersionedTextDocumentIdentifier
    JSON.mapping({
      version: Int32,
      uri: String
    }, true)
  end

end