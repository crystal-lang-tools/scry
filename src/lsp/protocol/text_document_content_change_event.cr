module LSP::Protocol
  struct TextDocumentContentChangeEvent
    JSON.mapping({
      range:        Range?,
      range_length: {type: Int32?, key: "rangeLength"},
      text:         String,
    }, true)
  end
end
