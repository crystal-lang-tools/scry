module Scry
  struct Context
    def test_send_init(root_path)
      test_send_request "initialize", %({ "processId": 1, "rootPath": "#{root_path}", "capabilities": {} , "trace": "off"})
    end

    def test_send_did_open(file_path, text)
      test_send_notification "textDocument/didOpen", %({"textDocument":{"uri":"#{file_path}", "languageId":"crystal","version":1,"text":#{text.dump} }})
    end

    def test_send_completion(file_path, position)
      test_send_request "textDocument/completion", %({"textDocument":{"uri":"#{file_path}"},"position":#{position}})
    end

    def test_send_notification(method, params)
      test_send %({ "jsonrpc": "2.0", "method": "#{method}", "params": #{params}})
    end

    def test_send_request(method, params)
      test_send %({ "jsonrpc": "2.0", "id": 1, "method": "#{method}", "params": #{params}})
    end

    def test_send(message)
      dispatch(Message.new(message).parse)
    end
  end
end
