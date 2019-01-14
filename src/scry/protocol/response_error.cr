module Scry::Protocol
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

  struct ResponseError
    JSON.mapping({
      code:    ErrorCodes,
      message: String,
      data:    Array(String)?,
    }, true)

    def initialize(@message, @data, @code = ErrorCodes::UnknownErrorCode)
    end
  end
end
