require "./response_error"
require "./text_edit"
require "./location"

module Scry
  # Add a response type when needed
  alias ResponseTypes = Array(TextEdit) | Array(Location)

  struct ResponseMessage
    JSON.mapping({
      jsonrpc: String,
      id:      Int32 | String | Nil,
      result:  ResponseTypes?,
      error:   ResponseError?,
    }, true)

    @jsonrpc = "2.0"

    def initialize(@id, @result)
    end

    def initialize(@result)
    end

    def initialize(ex : Exception)
      @error = ResponseError.new(
        ex.message || "Unknown error",
        ex.backtrace
      )
    end
  end
end
