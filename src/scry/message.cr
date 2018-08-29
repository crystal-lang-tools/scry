module Scry
  class InvalidContentError < Exception
  end

  alias ProtocolMessage = Protocol::RequestMessage | Protocol::NotificationMessage

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
