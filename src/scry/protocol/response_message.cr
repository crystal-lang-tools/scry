module Scry::Protocol
  # Add a response type when needed
  alias ResponseTypes = Array(TextEdit) | Array(Location) | Array(SymbolInformation) | Array(CompletionItem) | CompletionItem | Hover

  struct ResponseMessage
    JSON.mapping({
      jsonrpc: String,
      id:      {type: Int32 | String | Nil, emit_null: true},
      result:  ResponseTypes?,
      error:   ResponseError?,
    }, true)

    @jsonrpc = "2.0"

    def initialize(@id, @result)
    end

    def initialize(@result)
    end

    def initialize(ex : Exception)
      @error = ResponseError.new(ex)
    end
  end
end
