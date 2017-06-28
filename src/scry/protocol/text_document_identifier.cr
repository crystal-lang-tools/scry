require "json"

module Scry

  struct TextDocumentIdentifier
    JSON.mapping({
      uri: String
    }, true)
    def initialize(@uri = "")
    end
    def to_file_path
      @uri.uri.match(/file:\/\/(.*)/)[1]
    end
  end

end