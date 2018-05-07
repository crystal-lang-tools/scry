require "json"

module Scry
  struct Hover
    JSON.mapping({
      contents: MarkupContent,
      range:    Range?,
    })

    def initialize(@contents, @range = nil)
    end
  end
end
