require "json"

module Scry
  struct Position
    JSON.mapping({
      line:      Int32,
      character: Int32,
    }, true)

    def initialize(@line, @character)
    end
  end
end
