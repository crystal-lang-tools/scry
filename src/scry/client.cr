require "./request"

module Scry
  class Client
    alias ClientMessage = Protocol::Initialize | Protocol::ResponseMessage | Protocol::NotificationMessage

    getter io_out

    def initialize(@io_in : IO, @io_out : IO)
    end

    def read
      Request.new(@io_in)
    end

    def send(method_name : String, params : Protocol::NotificationType)
      notification_message = Protocol::NotificationMessage.new(method_name, params)
      send_message(notification_message)
    end

    def send(method_name : String, params : Protocol::ResponseTypes)
      response_message = Protocol::ResponseMessage.new(method_name, params)
      send_message(response_message)
    end

    def send_message(client_messages : Array(ClientMessage))
      client_messages.each do |client_message|
        send_message(client_message)
      end
    end

    def send_message(client_message : ClientMessage)
      io_out << prepend_header(client_message.to_json)
      io_out.flush
    end

    private def prepend_header(content : String)
      "Content-Length: #{content.bytesize}\r\n\r\n#{content}"
    end
  end
end
