require "./protocol/notification_message"
require "./protocol/request_message"

module Scry
  class InvalidContentError < Exception
  end

  alias ProtocolMessage = RequestMessage | NotificationMessage

  struct Message
    def initialize(@json : String)
    end

    def initialize(@json : Nil)
      raise InvalidContentError.new("Expected procedure content")
    end

    def parse
      ProtocolMessage.from_json(@json || "")
    end
  end
end
