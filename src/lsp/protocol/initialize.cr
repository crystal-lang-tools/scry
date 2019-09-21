module LSP::Protocol
  struct Initialize
    JSON.mapping(
      jsonrpc: String,
      id: Int32,
      result: InitializeResult
    )

    def initialize(msg_id : Int32)
      @jsonrpc = "2.0"
      @id = msg_id
      @result = InitializeResult.new
    end
  end
end
