module LSP::Protocol
  struct LogMessageParams
    JSON.mapping({
      type:    MessageType,
      message: String?,
    }, true)

    def initialize(@type, @message)
    end
  end
end
