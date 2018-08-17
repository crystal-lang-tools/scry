require "logger"
require "./client"
require "./protocol/log_message_params"

module Scry
  module Log
    class_property logger : Logger = Logger.new(nil)

    class ClientLogger < Logger
      def initialize(@client : Client)
        super(@client.io)
      end

      private def write(severity, datetime, progname, message)
        message_type = case severity
                       when INFO
                         Protocol::MessageType::Info
                       when WARN
                         Protocol::MessageType::Warning
                       when ERROR, FATAL
                         Protocol::MessageType::Error
                       else
                         Protocol::MessageType::Log
                       end
        @client.send("window/logMessage", Protocol::LogMessageParams.new(message_type, message.to_s))
      end
    end
  end
end
