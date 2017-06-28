require "json"
require "./position"

module Scry
  
  struct Range
    JSON.mapping({
      start: Position,
      end: Position
    }, true)

    def initialize(@start, @end)
    end
  end

end