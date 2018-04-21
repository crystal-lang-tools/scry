module Scry
  module ProtocolHelper
    def self.send_init(context, root_path)
      message = %({ "jsonrpc": "2.0", "id": 1, "method": "initialize", "params": { "processId": 1, "rootPath": "#{root_path}", "capabilities": {} , "trace": "off"}})
      response = context.dispatch(Message.new(message).parse)
    end

    def self.send_message(context, message)

    end
  end
end
