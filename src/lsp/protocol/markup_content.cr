module LSP::Protocol
  struct MarkupContent
    JSON.mapping({
      kind:  String,
      value: String,
    })

    def initialize(@kind, @value)
    end
  end
end
