module Scry::Protocol
  struct TextEdit
    JSON.mapping(
      range: Range,
      newText: String
    )

    def initialize(@range, @newText)
    end
  end
end
