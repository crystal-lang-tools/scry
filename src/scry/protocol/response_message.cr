module Scry
  struct ResponseTextDocumentSync
    JSON.mapping(
      textDocumentSync: Int32
    )
    def initialize(@textDocumentSync)
    end
  end

  struct ResponseResult
    JSON.mapping(
      capabilities: ResponseTextDocumentSync
    )
    def initialize(@capabilities)
    end
  end

  abstract struct ResponseMessage
    JSON.mapping(
      jsonrpc: String,
      id: Int32,
      result: ResponseResult
    )

    def initialize(@id, textDocumentSync : Int32)
      @jsonrpc = "2.0"
      @result = ResponseResult.new(ResponseTextDocumentSync.new(textDocumentSync))
    end

  end
end
