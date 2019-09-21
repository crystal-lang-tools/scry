module Scry::Protocol
  struct FormattingOptions
    JSON.mapping({
      tabSize:      Int32,
      insertSpaces: Bool,
    }, true)
  end
end
