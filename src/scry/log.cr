require "log"
require "log/entry"
require "./client"

module Scry
  Log = ::Log.for(self)

  class ClientLogBackend < ::Log::IOBackend
    def initialize(@client : Client)
      super(@client.io)
    end

    def write(entry : ::Log::Entry)
      message_type = case entry.severity
                     when ::Log::Severity::Info
                       LSP::Protocol::MessageType::Info
                     when ::Log::Severity::Warn
                       LSP::Protocol::MessageType::Warning
                     when ::Log::Severity::Error, ::Log::Severity::Fatal
                       LSP::Protocol::MessageType::Error
                     else
                       LSP::Protocol::MessageType::Log
                     end
      @client.send("window/logMessage", LSP::Protocol::LogMessageParams.new(message_type, entry.message))
    end
  end
end
