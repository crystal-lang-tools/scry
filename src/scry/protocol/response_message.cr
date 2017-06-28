module Scry

  struct ResponseResult
    JSON.mapping(
      capabilities: CrystalServerCapabilities
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

    def initialize(@id, crystal_server_capabilities)
      @jsonrpc = "2.0"
      @result = ResponseResult.new(
        crystal_server_capabilities
      )
    end

  end
end
