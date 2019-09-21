module Scry
  class InvalidContentError < Exception
  end

  alias LSP::ProtocolMessage = LSP::Protocol::RequestMessage | LSP::Protocol::NotificationMessage

  module Message
    def self.from(json : String?)
      raise InvalidContentError.new("Expected procedure content") unless json

      LSP::ProtocolMessage.from_json(json)
    end
  end
end
