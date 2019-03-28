require "./request"

module Scry
  class Client
    alias ClientMessage = Protocol::Initialize | Protocol::ResponseMessage | Protocol::NotificationMessage

    getter output

    def initialize(@input : IO, @output : IO)
    end

    def read
      Request.new(@input)
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
      output << prepend_header(client_message.to_json)
      output.flush
    end

    private def prepend_header(content : String)
      "Content-Length: #{content.bytesize}\r\n\r\n#{content}"
    end
  end
end
