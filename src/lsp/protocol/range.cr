module LSP::Protocol
  struct Range
    JSON.mapping({
      start: Position,
      end:   Position,
    }, true)

    def initialize(@start, @end)
    end
  end
end
