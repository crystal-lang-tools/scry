require "json"

module Scry
  struct FormattingOptions
    JSON.mapping({
      tabSize:      Int32,
      insertSpaces: Bool,
    }, true)
  end
end
