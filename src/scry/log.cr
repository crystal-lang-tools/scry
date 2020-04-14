require "log"
require "./client"
require "logger"
require "log/entry"

module Scry
  module Log
    class_property logger : ::Log = ::Log.for("scry")

    class ClientLogger < ::Log::Backend
      def initialize(@client : Client)
      end

      def write(entry : ::Log::Entry)
        message_type = case entry.severity
        when ::Log::Severity::Info
          LSP::Protocol::MessageType::Info
        when ::Log::Severity::Warning
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
end
