module Scry
  struct Context
    def test_send_init( root_path)
      message = %({ "jsonrpc": "2.0", "id": 1, "method": "initialize", "params": { "processId": 1, "rootPath": "#{root_path}", "capabilities": {} , "trace": "off"}})
      dispatch(Message.new(message).parse)
    end
  end
end
