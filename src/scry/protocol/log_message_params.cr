require "json"
require "./message_type"

module Scry::Protocol
  struct LogMessageParams
    JSON.mapping({
      type:    MessageType,
      message: String?,
    }, true)

    def initialize(@type, @message)
    end
  end
end
