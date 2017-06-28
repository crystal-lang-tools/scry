require "json"
require "./range"

module Scry

  struct TextDocumentContentChangeEvent
    JSON.mapping({
      range: Range?,
      range_length: {type: Int32?, key: "rangeLength"},
      text: String
    }, true)
  end
end