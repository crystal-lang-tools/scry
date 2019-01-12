module Scry
  class InvalidContentError < Exception
  end

  alias ProtocolMessage = Protocol::RequestMessage | Protocol::NotificationMessage

  struct Message
    def self.from(json : String?)
      raise InvalidContentError.new("Expected procedure content") unless json
      
      ProtocolMessage.from_json(json)
    end
  end
end
