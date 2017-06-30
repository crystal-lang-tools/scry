require "./server_capabilities"

module Scry
  struct InitializeResult
    JSON.mapping(
      capabilities: ServerCapabilities
    )

    def initialize
      @capabilities = ServerCapabilities.new
    end
  end
end
