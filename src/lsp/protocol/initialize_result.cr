module LSP::Protocol
  struct InitializeResult
    JSON.mapping(
      capabilities: ServerCapabilities
    )

    def initialize
      @capabilities = ServerCapabilities.new
    end
  end
end
