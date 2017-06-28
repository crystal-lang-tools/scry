require "json"
require "./text_document_identifier"
require "./position"
require "compiler/crystal/syntax/location"

module Scry
  struct TextDocumentPositionParams
    JSON.mapping({
      text_document: {type: TextDocumentIdentifier, key: "textDocument"},
      position: Position
    }, true)
    
    def to_location
      Location.new(@text_document.to_file_path, @position.line, @position.character)
    end
  end
end