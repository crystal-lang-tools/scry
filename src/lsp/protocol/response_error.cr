module LSP::Protocol
  enum ErrorCodes
    # Defined by JSON RPC
    ParseError           = -32700
    InvalidRequest       = -32600
    MethodNotFound       = -32601
    InvalidParams        = -32602
    InternalError        = -32603
    ServerErrorStart     = -32099
    ServerErrorEnd       = -32000
    ServerNotInitialized = -32002
    UnknownErrorCode     = -32001

    # Defined by the protocol.
    RequestCancelled = -32800
  end

  class ProtocolException < Exception
    getter code

    def initialize(
      @message : String? = nil,
      @cause : Exception? = nil,
      @code : ErrorCodes = ErrorCodes::UnknownErrorCode
    )
    end
  end

  struct ResponseError
    JSON.mapping({
      code:    ErrorCodes,
      message: String,
      data:    Array(String)?,
    }, true)

    def initialize(@message, @data = nil, @code = ErrorCodes::UnknownErrorCode)
    end

    def self.new(ex : Exception)
      new(ex.message || "Unknown error", ex.backtrace?)
    end

    def self.new(ex : ProtocolException)
      new(ex.message || "An error occurred", ex.backtrace?, ex.code)
    end
  end
end
