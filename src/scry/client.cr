require "./protocol/initialize"
require "./protocol/response_message"
require "./protocol/notification_message"

module Scry
  class Client
    alias ClientMessage = Initialize | ResponseMessage | NotificationMessage

    getter io

    def initialize(@io : IO)
    end

    def send(method_name : String, params : NotificationType)
      notification_message = NotificationMessage.new(method_name, params)
      send_message(notification_message)
    end

    def send(method_name : String, params : ResponseTypes)
      response_message = ResponseMessage.new(method_name, params)
      send_message(response_message)
    end

    def send_message(client_messages : Array(ClientMessage))
      client_messages.each do |client_message|
        send_message(client_message)
      end
    end

    def send_message(client_message : ClientMessage)
      io << prepend_header(client_message.to_json)
      io.flush
    end

    private def prepend_header(content : String)
      "Content-Length: #{content.bytesize}\r\n\r\n#{content}"
    end
  end
end
