module Scry
  class InvalidContentError < Exception
  end

  alias ProtocolMessage = LSP::Protocol::RequestMessage | LSP::Protocol::NotificationMessage

  module Message
    def self.from(json : String?)
      raise InvalidContentError.new("Expected procedure content") unless json

      ProtocolMessage.from_json(json)
    end
  end
end
